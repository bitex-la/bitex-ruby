class String
  def is_numeric?
    true if Integer(self)
  rescue
    false
  end
end
