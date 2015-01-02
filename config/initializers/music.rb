music_yaml = File.join(Rails.root, "config/music.yml")
ActividMusic = YAML.load(File.read(music_yaml))["categories"]
