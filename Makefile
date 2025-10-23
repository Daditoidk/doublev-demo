FLUTTER=apps/flutter_user_addresses
DOTNET=services/dotnet-api
ANGULAR=web/angular-admin

.PHONY: all flutter dotnet angular test ci

all: dotnet flutter angular

dotnet:
	cd $(DOTNET) && dotnet run

flutter:
	cd $(FLUTTER) && flutter run -d chrome --dart-define=API_BASE=http://localhost:5000

flutter-mobile:
	cd $(FLUTTER) && flutter run --dart-define=API_BASE=http://10.0.2.2:5000

angular:
	cd $(ANGULAR) && npm start

test:
	cd $(FLUTTER) && flutter test
	cd $(ANGULAR) && npm test -- --runInBand
	# dotnet tests optional if you add a test project

ci:
	echo "CI runs in .github/workflows/ci.yml"
