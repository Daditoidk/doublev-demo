FLUTTER=apps/flutter_user_addresses
DOTNET=services/dotnet-api

.PHONY: all flutter dotnet  test ci

all: dotnet flutter 

dotnet:
	cd $(DOTNET) && dotnet run

flutter:
	cd $(FLUTTER) && flutter run -d chrome --dart-define=API_BASE=http://localhost:5124

flutter-mobile:
	cd $(FLUTTER) && flutter run --dart-define=API_BASE=http://10.0.2.2:5124

test:
	cd $(FLUTTER) && flutter test
	# dotnet tests optional if you add a test project

ci:
	echo "CI runs in .github/workflows/ci.yml"
