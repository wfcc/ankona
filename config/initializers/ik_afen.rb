
__END__
#Object.send(:remove_const, :PieceBlock)
class PieceBlock < BinData::Record
  #array :pieces, read_until: lambda {element.kind == 0b110} do
  array :pieces, read_until: :eof do
  #array :pieces do
    bit3 :kind
    choice :piece, selection: lambda {:kind != 0b110} do
      struct true do
        bit8 :fairy_piece, onlyif: lambda {kind == 0b111}
        bit3 :xx
        bit3 :yy
      end
      bit0 false
    end

  end
  bit3 :terminator, initial_value: 0b110
end

#Object.send(:remove_const, :Ttest)
class Ttest < BinData::Record
  array :pieces, read_until: lambda {puts element.a; element.a == 'x'} do
    struct do
      string :a, length: 1
      bit8 :b
    end
  end
end
tt = Ttest.new
