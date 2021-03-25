# bapp

null safety is added, still needs "--no-sound-null-safety" flag to run as most of the packages doesnt support null safety yet

## taste  - bapps very own dead simple flavor management
add any files that needs to be flavorized to the `files_to_flavorize` of flavors.json inside flavors folder

create a key of new flavor and add alternate files to be considered for this flavor file keys in ths flavors.json should match
run `flutter pub run taste <your_flavor_name>` to switch to flavor, flavor will be maintained across git commits, so make sure to switch to needed flavor just to be sure.