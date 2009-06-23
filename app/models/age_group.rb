class AgeGroup < ActiveRecord::Base
  belongs_to   :group

  validates_numericality_of :age, :only_integer => true, :message => "Åldern måste vara ett giltigt heltal."
  validates_numericality_of :quantity, :only_integer => true, :message => "Antalet måste vara ett giltigt heltal."
end
