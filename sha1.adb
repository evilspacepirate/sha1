-----------------------------------------------------------------
--                                                             --
-- SHA1                                                        --
--                                                             --
-- Computes SHA1 sum of file specified by first argument       --
-- and prints SHA1 sum to standard out.                        --
--                                                             --
-- usage: sha1 <file name>                                     --
--                                                             --
--                                                             --
-- Copyright (c) 2016, John Leimon                             --
--                                                             --
-- Permission to use, copy, modify, and/or distribute          --
-- this software for any purpose with or without fee           --
-- is hereby granted, provided that the above copyright        --
-- notice and this permission notice appear in all copies.     --
--                                                             --
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR             --
-- DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE       --
-- INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY         --
-- AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE         --
-- FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL         --
-- DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS       --
-- OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF            --
-- CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING      --
-- OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF      --
-- THIS SOFTWARE.                                              --
-----------------------------------------------------------------
with ada.command_line,
     ada.io_exceptions,
     ada.streams,
     ada.streams.stream_io,
     ada.text_io,
     gnat.sha1;
use  ada.command_line,
     ada.streams,
     ada.text_io;
procedure sha1 is
   max_read_block_size : constant stream_element_offset := 4096;
begin
    if argument_count /= 1 then
       put_line("usage: sha1 <file name>");
       return;
    end if;

    declare
       target_file : string renames argument(1);
       file_handle : stream_io.file_type;
       buffer      : stream_element_array(1 .. max_read_block_size);
       last        : stream_element_offset;
       sha1context : gnat.sha1.context;
    begin
       ada.streams.stream_io.open(file_handle,
                                  stream_io.in_file,
                                  target_file);
       loop
          -- Read a block and update the sha1 --
          stream_io.read(file_handle, buffer, last);
          gnat.sha1.update(sha1context, buffer(1 .. last));
          exit when last < buffer'last;
       end loop;
       stream_io.close(file_handle);
       -- Compute and display the sha1 digest --
       put_line(gnat.sha1.digest(sha1context) & "  " & target_file);
    end;

exception
   when ada.io_exceptions.name_error =>
      put_line("Error: Cannot open file: '" & argument(1) & "'");
end sha1;
