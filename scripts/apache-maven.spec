%define major_ver YOURCOMPONENT_VERSION
%define service_name apache-maven
%define build_release BUILD_TIME

Name: %{service_name}
Version: %{major_ver}
Release: %{build_release}%{?dist}
Summary: Java project management and project comprehension tool.
License: Apache Lisence v2 (http://www.apache.org/licenses/LICENSE-2.0)
Group: Development/Tools
URL: http://maven.apache.org/
Source: %{service_name}-%{major_ver}.tar.gz
BuildRoot: %{_tmppath}/%{service_name}-root
Requires: jdk >= 1.6
Provides: apache-maven

%description
Apache Maven is a software project management and comprehension tool. 
Based on the concept of a project object model (POM), 
Maven can manage a project's build, reporting and documentation from 
a central piece of information.

#%prep

%setup -q -n %{service_name}-%{major_ver}

#%build

%install
rm -rf %{buildroot}
echo "_datadir=%{_datadir}"
echo "_bindir=%{_bindir}"
echo "_sysconfdir=%{_sysconfdir}"
install -dm 755 %{buildroot}%{_bindir}
install -dm 755 %{buildroot}%{_datadir}/%{service_name}/{bin,boot,conf/logging,lib/ext}
install -dm 755 %{buildroot}%{_datadir}/java/%{service_name}
install -dm 755 %{buildroot}%{_sysconfdir}/%{service_name}
install -m 755 README.txt         %{buildroot}%{_datadir}/%{service_name}/README.txt
install -m 755 LICENSE            %{buildroot}%{_datadir}/%{service_name}/LICENSE
install -m 755 NOTICE             %{buildroot}%{_datadir}/%{service_name}/NOTICE
install -m 755 bin/mvn            %{buildroot}%{_datadir}/%{service_name}/bin
install -m 755 bin/mvnDebug       %{buildroot}%{_datadir}/%{service_name}/bin
install -m 755 bin/mvnyjp         %{buildroot}%{_datadir}/%{service_name}/bin
install -m 644 bin/m2.conf        %{buildroot}%{_sysconfdir}/%{service_name}
install -m 644 conf/settings.xml  %{buildroot}%{_sysconfdir}/%{service_name}
install -m 644 lib/*.jar          %{buildroot}%{_datadir}/java/%{service_name}
install -m 644 lib/ext/README.txt %{buildroot}%{_datadir}/%{service_name}/lib/ext/README.txt

#%__install -dm 755 %{buildroot}%{_defaultdocdir}/%{service_name}-%{version}
# Install symlinks
ln -s %{_datadir}/%{service_name}/bin/mvn         %{buildroot}%{_bindir}/mvn
ln -s %{_datadir}/%{service_name}/bin/mvnDebug    %{buildroot}%{_bindir}/mvnDebug
ln -s %{_datadir}/%{service_name}/bin/mvnyjp      %{buildroot}%{_bindir}/mvnyjp
ln -s %{_sysconfdir}/%{service_name}/m2.conf      %{buildroot}%{_datadir}/%{service_name}/bin/m2.conf
ln -s %{_sysconfdir}/%{service_name}/settings.xml %{buildroot}%{_datadir}/%{service_name}/conf/settings.xml

pushd %{buildroot}%{_datadir}/java/%{service_name}
   for i in *.jar
   do
      ln -s "%{_datadir}/java/%{service_name}/$i" "%{buildroot}%{_datadir}/%{service_name}/lib/$i"
   done
popd
install -m 644 boot/plexus-classworlds-2.5.1.jar  %{buildroot}%{_datadir}/java/%{service_name}
ln -s %{_datadir}/java/%{service_name}/plexus-classworlds-2.5.1.jar \
   %{buildroot}%{_datadir}/%{service_name}/boot/plexus-classworlds-2.5.1.jar

#ln -s /usr/local/lib/libboost_date_time-mt.a /usr/local/lib/libboost_date_time.a
#ln -s /usr/local/lib/libboost_date_time-mt.so /usr/local/lib/libboost_date_time.so

%clean
rm -rf %{buildroot}

%files
%defattr(-, root, root)
%{_bindir}/*
%{_sysconfdir}/*
%{_datadir}/%{service_name}
%{_datadir}/java/%{service_name}

%changelog
* Fri May 09 2015 Andrew Lee
- Initial working version of RPM spec file. A minor fix to create conf/logging on the fly, and add license info.

