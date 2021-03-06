--
--

delimiter //

drop function if exists _get_mxarray_element //

create function _get_mxarray_element(
   array_id int unsigned,
   array_key varchar(127) charset utf8
) returns text charset utf8
comment 'Get an element by array id and key'
language SQL
deterministic
no sql
sql security invoker

main_body: begin
  declare xpath varchar(64) charset utf8;
  if _mxarray_key_exists(array_id, array_key) then
    set xpath := CONCAT('/ma/a[@id="', array_id, '"]/e[@key="', encode_xml(array_key), '"][1]');
    return decode_xml(ExtractValue(@_common_schema_mx_array, xpath));
  end if;
  return null;
end;
//

delimiter ;
