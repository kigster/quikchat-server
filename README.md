# QuikChat



## Development setup

 1. `git clone`
 2. `bin/setup`
 3. After changing Gemfile, run `bin/setup` again
 4. For a client use `quickchat` gem, with settings:

```
quikchat:
  url: 'http://localhost:3003'
```

## Bundler!

Running the `setup` script configures bundler such a way that it runs really really really fast. In order to make this
happen, the ascii bytes making up the core of this application have been replaced with arcane runes and other symbols
in a ritual of the deepest and darkest black magic. No animals were harmed, unless you count the poor animal brains
that are indelibly scarred and no longer view the world in the same way.

What this means?

Bundler does not automatically require any gems. If adding a gem, please manually require it in `application.rb`.

## Deployment

```bash
cap production deploy
```

