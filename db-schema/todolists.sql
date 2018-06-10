--

CREATE TABLE IF NOT EXISTS todolists (
  id  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  date  DATETIME NOT NULL,
  name  VARCHAR(255) NOT NULL,
  tasks TEXT NOT NULL,
  PRIMARY KEY (id),
  INDEX idx_name (name),
  INDEX idx_date (date)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8