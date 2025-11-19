FLUTTER := flutter

all: help

clean:
	$(FLUTTER) clean
	$(FLUTTER) pub get
	@echo "✓ Project cleaned"

pub-get:
	$(FLUTTER) pub get

pub-upgrade:
	$(FLUTTER) pub upgrade

run:
	$(FLUTTER) run

test:
	$(FLUTTER) test

format:
	$(FLUTTER) format .

doctor:
	$(FLUTTER) doctor -v


build-apk:
	$(FLUTTER) build apk --release

build-appbundle:
	$(FLUTTER) build appbundle --release

build-ios:
	$(FLUTTER) build ios --release

build-web:
	$(FLUTTER) build web --release


clean-build:
	rm -rf build/
	@echo "✓ Build folder removed"


build-runner:
	$(FLUTTER) pub run build_runner build --delete-conflicting-outputs

watch-runner:
	$(FLUTTER) pub run build_runner watch --delete-conflicting-outputs


help:
	@echo ""
	@echo "=== Flutter Makefile Commands ==="
	@echo "make clean              - Bersihkan project + pub get"
	@echo "make pub-get           - Install depedencies"
	@echo "make pub-upgrade       - Upgrade dependencies"
	@echo "make run               - Jalankan aplikasi"
	@echo "make test              - Jalankan unit tests"
	@echo "make format            - Format kode"
	@echo "make doctor            - Periksa environment"
	@echo "make build-apk         - Build APK release"
	@echo "make build-appbundle   - Build AAB release"
	@echo "make build-ios         - Build iOS release"
	@echo "make build-web         - Build Web release"
	@echo "make build-runner      - Jalankan build_runner"
	@echo "make watch-runner      - Watch mode build_runner"
	@echo "make clean-build       - Hapus folder build/"
	@echo ""
