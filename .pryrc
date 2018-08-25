# frozen_string_literal: true

# .pryrc
require 'awesome_print'
AwesomePrint.defaults = {
  indent: 2
}
# refs: https://github.com/steakknife/pry-awesome_print/blob/master/lib/pry-awesome_print.rb
Pry.print = proc do |_output, value, pry|
  pry.pager.open do |pager|
    pager.print pry.config.output_prefix
    pager.puts value.ai
  end
end
