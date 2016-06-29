class User < ActiveRecord::Base

  attr_reader :name, :gender

  def name
    "#{first_name} #{last_name}"
  end

  def to_s
    name
  end

end
