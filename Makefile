FLUTTER=apps/flutter_user_addresses
DOTNET=services/dotnet-api
DOTNETTEST=services/dotnet-api.Tests

.PHONY: all flutter dotnet test-dotnet test-flutter

all: test-dotnet dotnet test-flutter flutter 

dotnet:
	cd $(DOTNET) && dotnet run

flutter:
	cd $(FLUTTER) && flutter run -d chrome --dart-define=API_BASE=http://localhost:5124

flutter-mobile:
	cd $(FLUTTER) && flutter run --dart-define=API_BASE=http://10.0.2.2:5124

test-dotnet:
	cd $(DOTNETTEST) && dotnet test

test-flutter:
	cd $(FLUTTER) && flutter test

	
