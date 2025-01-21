Name:           scarlett4-firmware
Version:        2403
Release:        1%{?dist}
Summary:        Firmware for Focusrite devices supported by the FCP driver

License:        Redistributable, no modification permitted
URL:            https://github.com/geoffreybennett/scarlett4-firmware
Source0:        %{name}-%{version}.tar.xz

BuildArch:      noarch
BuildRequires:  make

%description
Firmware files for the Focusrite Scarlett 4th Gen 16i16, 18i16, and
18i20 audio interfaces.

%prep
%setup -q

%build
# Nothing to build, firmware files are binary

%install
mkdir -p %{buildroot}/usr/lib/firmware/scarlett4
install -pm 644 firmware/*.bin %{buildroot}/usr/lib/firmware/scarlett4/
mkdir -p %{buildroot}/usr/share/licenses/scarlett4-firmware
install -pm 644 LICENSE.Focusrite %{buildroot}/usr/share/licenses/scarlett4-firmware/

%files
/usr/lib/firmware/scarlett4
/usr/share/licenses/scarlett4-firmware

%changelog
* Tue Dec 24 2024 Geoffrey D. Bennett <g@b4.vu> - 2403-1
- Initial RPM release of the Scarlett4 firmware files.
