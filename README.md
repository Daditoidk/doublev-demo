# DoubleV Demo

Simple multi-platform sample that pairs a .NET Web API backend with a Flutter front end.  
All developer workflows are scripted through the top-level `Makefile`.

## Prerequisites

- [.NET 8 SDK](https://dotnet.microsoft.com/) (for `services/dotnet-api`)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (for `apps/flutter_user_addresses`)
- Recommended: Chrome browser for the web runner, or a configured emulator/device if you plan to use the `flutter-mobile` target.

## Step-by-step: Run Everything with Make

1. **Execute the .NET unit/integration tests**
   ```bash
   make test-dotnet
   ```

2. **Start the .NET API**  
   ```bash
   make dotnet
   ```  
   The API listens on `http://localhost:5124`; interactive docs are exposed at `http://localhost:5124/swagger`.

_In a new terminal_

3. **Run the Flutter tests**
   ```bash
   make test-flutter
   ```

4. **Launch the Flutter app (web target)**  
   ```bash
   make flutter
   ```  
   This runs `flutter run -d chrome` and points the app at the local API using `API_BASE=http://localhost:5124`.

### Optional: Run on a mobile emulator/device

If you prefer Android/iOS instead of the Chrome runner, with the API already running:
```bash
make flutter-mobile
```
By default it uses `API_BASE=http://10.0.2.2:5124` so the app can reach the backend from an Android emulator.

---

Stop the `make dotnet` server run (step 2) with `Ctrl+C` when you are finished.
