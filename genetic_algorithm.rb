# File::     genetic_algorithm.rb
# LastEdit:: yoshitake 07-Mar-2015

class Gene
  attr_reader :gene
  attr_reader :fitness

  def initialize(gene, fitness)
    @gene    = gene
    @fitness = fitness
  end

  def <=>(a)
    fitness <=> a.fitness
  end

  def to_s
    "#{fitness}, #{gene}"
  end
end

class GeneticAlgorithm
  MUTATION_RATE           = 5
  NUM_OF_FIRST_CLASS_GENE = 3

  def initialize(initial_generation, option = {})
    @initial_generation      = initial_generation
    @mutation_rate           = option[:mutation_rate]           || MUTATION_RATE
    @num_of_first_class_gene = option[:num_of_first_class_gene] || NUM_OF_FIRST_CLASS_GENE

    @mutation = lambda do |x|
      child    = x
      i        = rand(child.size)
      child[i] += 1
      return child
    end

    @crossover = lambda do |x, y|
      i     = rand(x.size)
      child = x.first(i)
      child.concat(y.last(y.size - i))
      return child
    end
  end

  def evaluate(&block)
    @evaluate = block
  end

  def mutation(&block)
    @mutation = block
  end

  def crossover(&block)
    @mutation = block
  end

  def go_next(n=1)
    unless @current_generation
      @current_generation = []
      @initial_generation.each do |elem|
        @current_generation << Gene.new(elem, @evaluate.call(elem))
      end
    end

    n.times do
      go_next_one
    end
  end

  def top
    @current_generation.sort.last
  end

  def dump
    @current_generation.sort.each do |elem|
      puts elem
    end
  end

  private
  def elite
    @current_generation.sort.last(NUM_OF_FIRST_CLASS_GENE)
  end

  def go_next_one
    next_generation = elite
    remains         = @current_generation.size - next_generation.size

    remains.times do
      gene = if rand(100) <= @num_of_first_class_gene
               x = @current_generation.sample
               @mutation.call(x.gene)
             else
               x = @current_generation.sample
               y = @current_generation.sample
               @crossover.call(x.gene, y.gene)
             end
      next_generation << Gene.new(gene, @evaluate.call(gene))
    end

    @current_generation = next_generation
  end
end

# Log
# 07-Mar-2015 yoshitake Created.
