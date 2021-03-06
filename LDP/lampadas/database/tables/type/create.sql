CREATE TABLE type
(
	type_code		CHAR(20)	NOT NULL,
	sort_order		INT4		NOT NULL,
	created			TIMESTAMP	NOT NULL	DEFAULT now(),
	updated			TIMESTAMP	NOT NULL	DEFAULT now(),

	PRIMARY KEY (type_code)
);

CREATE INDEX type_upd_idx ON type (updated);
CREATE INDEX type_ctd_idx ON type (created);
