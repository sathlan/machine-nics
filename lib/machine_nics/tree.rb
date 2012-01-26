# -*- coding: utf-8 -*-
module MachineNics
  # Builds a tree as a associative array.  It takes an hash of an hash
  # as input whose root node is a machine's name (as a symbol).
  class Tree
    attr_reader :root
    attr_reader :parent_of
    attr_reader :children
    def initialize(machine_name)
      @root = machine_name
      # here, a nic is a hash.  This could be a class.
      @children = Hash.new([])
      @parent_of = Hash.new([])
    end

    # Add a node to the tree and link the node back to parent.
    def add(root,nics)
      @children[root] = nics
      nics.each {|nic| parent_of[nic] = root}
    end

    # parse a hash of hash of any depth with the machine name as unique
    # root.  Some syntaxic sugar is present for leaf.  Check the
    # sanitize function.
    # Ex:
    #     { bridge0: {tap101: nil, tap102: nil}}
    # can be written:
    #     { bridge0: [ tap101, tap102 ]}
    # This works too:
    #     {brigde0: [{ lagg0: [tap200, tap201] }, tap100]
    # and is équivalent to
    #     {bridge0: {lagg0: {tap200: nil, tap201: nil}, tap100: nil}
    def self.create_from_hash(description)
      machine = new(description.first[0])
      current_roots = []

      sanitized_values = sanitize(description[machine.root])
      machine.add(machine.root, sanitized_values.keys)
      current_roots = [sanitized_values]

      until current_roots.empty?
        current_roots.each do |current_root|
          current_roots = []
          current_root.each_key do |root|
            unless current_root[root].nil?
              sanitized_current_root = sanitize(current_root[root])
              machine.add(root, sanitized_current_root.keys)
              current_roots.push(sanitized_current_root)
            end
          end
        end
      end

      machine
    end
    # Get the length of the tree (TODO: rename to depth)
    def length(root)
      max = 0
      traverse(root,0) {|n, l| max = l if l > max }
      max
    end

    # Traverse the tree.
    def traverse(node,level,&block)
      yield node, level if block_given?
      @children[node].each { |child| traverse(child, level+1, &block) }
    end

    # Traverse the tree, depth first and deepest first.
    def traverse_df(node,level,&block)
      @children[node].sort_by {|a| length(a) }.reverse.each { |child| traverse_df(child, level+1, &block) }
      yield node, level if block_given?
    end

    # Utility: display the complete tree.
    def display
      puts @root.to_s + " " + "=" * 10
      traverse(@root,0) {|n, l| puts "  "*l + "node: #{n}"}
      self
    end
    # Display depth first.
    def display_df
      puts @root.to_s + " df*" + "=" * 10
      traverse_df(@root,0) {|n, l| puts "  "*l + "*node: #{n}"}
      self
    end

    private
    # Syntaxic sugar.  We expect an hash of a hash, but for terminal
    # node, we can take array or symbol.  Transforme the structure here
    # to make it fit our requirements.
    def self.sanitize(hash_or_array) # :doc:
      hash = {}
      if hash_or_array.class.name == "Array"
        hash_or_array.each do |element|
          # each eleement can be a terminal nic or a composed nic.
          if element.class.name == "Symbol"
            hash[element] = nil
          else
            element.each_key do |nic|
              hash[nic] = element[nic]
            end
          end
        end
      elsif hash_or_array.class.name == "Symbol"
        hash = {}
        hash[hash_or_array] = nil
      else
        hash = hash_or_array
      end
      hash
    end
  end
end
