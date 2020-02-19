# artsy/auto

This orb controls Artsy's package deployment process. It builds off of [a simple community orb](https://github.com/auto-it/orbs/blob/master/src/release/release.yml) that's itself a simple wrapper for [intuit's auto](https://github.com/intuit/auto).

If you're making a generic change about how `auto` executes, it's recommended you do that [upstream](https://github.com/auto-it/orbs/blob/master/src/release/release.yml). If you're actually changing something specific to how Artsy deploys, then this is the right place for it.
