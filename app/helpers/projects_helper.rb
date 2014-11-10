module ProjectsHelper
  def options_for_category_select
    Project::CATEGORIES.map do |k, v|
      ["#{v[:name]} - starting at $#{v[:starting_price]}", k]
    end
  end

  def options_for_desired_length_select
    Project::LENGTHS.map do |k, v|
      name = v[:additional_price] ? "#{v[:name]} - add $#{v[:additional_price]}" : v[:name]
      [name, k]
    end
  end
end
