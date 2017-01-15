require 'digest/md5'
require 'new_relic/agent/method_tracer'

class Conversation < ActiveRecord::Base
  include ::NewRelic::Agent::MethodTracer

  has_many :participants
  has_many :messages
  belongs_to :last_message, class_name: "Message"

  PER_PAGE = 20

  scope :page_for_user_id, -> (user_id, page: 1) {
    with_user_id(user_id).
      includes(:last_message).order('updated_at desc').limit(PER_PAGE).offset((page - 1) * PER_PAGE)
  }

  scope :with_user_id, -> (user_id) {
    ids = Participant.where(user_id: user_id).pluck(:conversation_id)
    includes(:participants).where(id: ids)
  }

  def self.find_last_posted_in_by_user_id(user_id)
    Message.where(user_id: user_id).order(:created_at).
      includes(:conversation).last.conversation
  end

  def self.find_or_create_by_user_ids(*user_ids)
    user_ids.flatten!
    chat = find_by_user_ids_hash(hash_ids(user_ids))
    chat ||
      Conversation.transaction do
        Conversation.connection.execute "SET LOCAL synchronous_commit TO 'ON'"
        new.tap do |c|
          user_ids.each do |uid|
            c.participants.build(user_id: uid)
          end
          c.save
        end
      end
  end

  def self.find_by_id_and_user_id(id, user_id)
    conversation = Conversation.find_by_id(id)
    if !conversation.blank? && conversation.user_ids.include?(user_id)
      conversation
    else
      nil
    end
  end

  def self.active_for_user_id(user_id)
    conversation = Participant.find_by_user_id_and_active(user_id, true).try(:conversation)
    conversation = Conversation.with_user_id(user_id).order('updated_at desc').limit(1).first unless conversation
    conversation
  end

  def self.unread_count_for_user_id(user_id)
    query = <<-SQL
      SELECT COUNT(DISTINCT conversations.id)
      FROM "conversations"
      INNER JOIN "participants" ON "participants"."conversation_id" = "conversations"."id"
      WHERE (participants.user_id = #{ActiveRecord::Base.sanitize(user_id)} AND (participants.last_read_at is NULL OR participants.last_read_at < conversations.updated_at))
    SQL
    result = Conversation.connection.execute(query).to_a
    if result && !result.empty? && result.first["count"]
      result.first["count"].to_i
    else
      0
    end
  end

  class << self
    include ::NewRelic::Agent::MethodTracer

    add_method_tracer :unread_count_for_user_id, 'Conversation/unread_count_for_user_id'
    add_method_tracer :page_for_user_id, 'Conversation/page_for_user_id'
  end

  before_validation :hash_user_ids

  def user_ids
    participants.map(&:user_id)
  end

  def create_message(attrs = {})
    message = messages.create!(attrs)
    update_attribute(:last_message_id, message.id)
    participant = Participant.find_by_user_id_and_conversation_id(attrs[:user_id], id)
    participant.last_read_at = Time.now
    unless participant.active?
      Participant.where(user_id: attrs[:user_id], active: true).update_all(active: false)
      participant.active = true
    end
    participant.save
    message
  end

  def mark_read!(user_id)
      participant = participants.find_by_user_id(user_id)
      participant.update_attribute(:last_read_at, Time.now) if participant
  end

  add_method_tracer :mark_read!, 'Conversation/mark_read!'

  protected

  def hash_user_ids
    self.user_ids_hash = self.class.hash_ids(user_ids)
  end

  def self.hash_ids(ids)
    Digest::MD5.hexdigest(ids.map(&:to_s).sort.join(","))
  end
end

