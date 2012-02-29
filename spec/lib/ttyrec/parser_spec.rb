require 'spec_helper'
require 'ttyrec'

# ttyrec format
#
# A ttyrec consists of many frames. Each frame is made up of a
# twelve-byte header and an arbitrarily long data block.
#
# The twelve-byte header contains two pieces of information: how much
# data is in this frame and a timestamp. The timestamp is very
# precise; it has microsecond precision. The header bytes are aligned
# like so:
#
# 1 2 3 4 5 6 7 8 9 A B C
# \-----/ \-----/ \-----/
#   sec     usec    len
#
# The bytes are in little-endian order (meaning least significant
# bytes first). You can portably read and process frames like this, in C:
#
# while (fread(header, 1, 12, stdin) == 12)
# {
#   sec  = (((((header[ 3] << 8) | header[ 2]) << 8) | header[1]) << 8) | header[0];
#   usec = (((((header[ 7] << 8) | header[ 6]) << 8) | header[5]) << 8) | header[4];
#   len  = (((((header[11] << 8) | header[10]) << 8) | header[9]) << 8) | header[8];
#
#   received = fread(data, 1, len, stdin)
#   if (len != received)
#     break;
#
#   /* process data */
# }
#
# /* either the ttyrec is done or we had an error */

describe TTYRec::Parser do

  subject do
    fixture_path = Rails.root.join('spec/fixtures/ttyrecord')
    record = File.open(fixture_path)
    TTYRec::Parser.new(record)
  end

  describe "#parse" do
    it "should return parsed ttyred" do
      subject.parse
    end
  end

  describe "to_typescript" do
    it "Should convert the record to typescript format" do
      subject.parse
      script = subject.to_typescript

      File.open('/tmp/typescript', 'wb') do |f|
        f.write(script[:typescript])
      end

      File.open('/tmp/timing', 'wb') do |f|
        f.write(script[:timing])
      end
    end
  end
end
