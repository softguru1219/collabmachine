namespace :test_db_migration do
  # run against prod mysql DB pulled locally
  task dump_samples: :environment do
    Rails.application.eager_load!

    samples = ActiveRecord::Base.descendants.reject(&:abstract_class).map do |klass|
      [
        klass.to_s,
        klass.all.select { |r| !r.respond_to?(:updated_at) || r.updated_at < (Date.today - 4.days) }.sample(40)
      ]
    end.to_h

    File.write(Rails.root.join("tmp/samples.yml"), samples.to_yaml)
  end

  # run against imported PG data
  task verify_samples: :environment do
    samples = YAML.safe_load(File.read(Rails.root.join("tmp/samples.yml")))

    samples.each do |_klass_name, klass_samples|
      klass_samples.each do |sample|
        sample_attrs = sample.attributes
        migrated = sample.class.find(sample.id)
        migrated_attrs = migrated.attributes

        puts "#{migrated.class}#{migrated.id}"

        sample_attrs.each do |key, value|
          migrated_value = migrated_attrs.fetch(key)

          next if value == migrated_value

          p value
          p migrated_value

          raise "DISCREPANCY - #{migrated.class}#{migrated.id}"
        end
      end
    end
  end
end
