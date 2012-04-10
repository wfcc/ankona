#Object.send(:remove_const, :PieceBlock)
class FairyPiece < BinData::Record
  bit7 :letter1
  bit7 :letter2
  bit1 :not_a
  bit6 :variety, onlyif: lambda {not_a != 0}
end

class PieceBlock < BinData::Record
  array :wbn, initial_length: 3 do
    array :color, read_until: lambda {element.kind == 0b110} do 
      bit3 :kind
      struct :piece, onlyif: lambda {kind != 0b110} do
        FairyPiece :fairy_piece, onlyif: lambda {kind == 0b111}
        array :xy, initial_length: 2, type: :bit3
      end
    end
  end
end

class FefBlock < BinData::Record
  bit8 :version
  PieceBlock :piece_block
end