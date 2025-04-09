### Depependencies

- https://github.com/go-chi/chi
- https://github.com/markbates/goth
- https://github.com/gorilla/sessions

### Development environment

Requirements:

- https://direnv.net/
- https://devenv.sh/ and [Automatic shell activation]

[Automatic shell activation]: https://devenv.sh/automatic-shell-activation/#configure-shell-activation


### Usage

Use `just` to see a list of available commands

@TODO: SQLITE for session store or custom memroy store (cookiestore not OK due to limit of 4KB in size)
@TODO: RBAC - how to extract roles from token?
@TODO: Realm export to have users and secrets pre-configured
