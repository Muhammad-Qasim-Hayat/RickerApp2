# ricker_app
<img src="ricker_app_demo.gif" alt="Demo" height="500">

## Configure
Please copy the `lib/config/app.example.dart` to `lib/config/app.dart` and modify with your environment settings.

## Run
```bash
flutter run
```

## Authenticating using an API
You must need an API to serve the authentication endpoints `/login` and `/me`.

| endpoint | method | body                | expected response                                                                                                 |
|----------|--------|---------------------|-------------------------------------------------------------------------------------------------------------------|
| /login   | POST   | { email, password } | {   user: {     id: 1,     name: 'Example',     email: 'example@example.com'   },   token: 'eyJ0eXAiOiJKV1Q...' } |
| /me      | GET    | null                | {   user: {     id: 1,     name: 'Example',     email: 'example@example.com'   } }                                |

## License
[MIT](LICENSE)
