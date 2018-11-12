# Open class to add numeric checker
class String
  def numeric?
    true if Integer(self)
  rescue ArgumentError
    false
  end
end
