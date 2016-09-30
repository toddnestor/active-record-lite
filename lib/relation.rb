class Relation
  attr_accessor :selects, :from, :wheres, :groups, :joins, :limit

  include Enumerable

  def initialize(calling_object)
    @caller = calling_object
    @selects = []
    @wheres = []
    @groups = []
    @joins = []
    @where_values = []
    @limit = nil
  end

  def where(params, comparator = '=')
    params.each do |key, val|
      @wheres << {col: key, value: '?', comparator: comparator.upcase}
      val = "%#{val}%" if comparator.upcase == 'LIKE' || comparator.upcase == 'ILIKE'
      @where_values << val
    end

    self
  end

  def select(*params)
    @selects += params
  end

  def each(&prc)
    self.load.each do |el|
      prc.call(el)
    end
  end

  def limit(limit)
    @limit = limit
  end

  def load
    @selects << '*' if @selects.empty?
    sql = @caller.build_select(@selects) + @caller.build_from(@joins) + @caller.build_where(@wheres) + @caller.build_limit(@limit)
    puts sql
    p @where_values
    @caller.get_objects(sql, *@where_values)
  end

  def objects
    @objects ||= load
  end

  def length
    objects.length
  end

  def ==(something)
    objects == something
  end

  def [](id)
    objects[id]
  end

  def first
    @limit = 1
    objects.first
  end

  def all
    objects
  end
end
