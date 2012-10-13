class String
  def split_screen_width(width = 40)
    s = i = r = 0
    self.each_char.inject([]) do |res,c|
       i += c.ascii_only? ? 1 : 2
       r += 1
       next res if i < width

       res << self[s,r]
       s += r
       i = r = 0
       res
    end << self[s,r]
  end
end
