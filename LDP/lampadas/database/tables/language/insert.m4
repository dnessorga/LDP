m4_define(insert, [INSERT INTO language(lang_code, supported, encoding)
VALUES ('$1', '$2', '$3');])m4_dnl
m4_define(true, insert($1, t))m4_dnl
m4_define(false, insert($1, f))m4_dnl
