-- 4096 rows, 1000 rows per split step
SET @s := '
  set @counter := 0;
  update test_cs.test_split_text set nval = 1;
  split(update test_cs.test_split_text set nval = nval + 1)
  {
    set @counter := @counter + 1;
  }
  ';
call run(@s);

select @counter = 5;

