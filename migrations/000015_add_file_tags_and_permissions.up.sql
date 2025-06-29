-- Tabel untuk menghubungkan file ke satu atau lebih tag
CREATE TABLE file_tags (
    file_id UUID NOT NULL REFERENCES files(id) ON DELETE CASCADE,
    tag_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (file_id, tag_name)
);

-- Tabel untuk mendefinisikan peran mana yang dapat mengakses tag mana
CREATE TABLE file_access_rules (
    tag_name VARCHAR(100) NOT NULL,
    role_name VARCHAR(100) NOT NULL, -- Merujuk ke `name` di tabel `roles` di db lain
    PRIMARY KEY (tag_name, role_name)
);

-- Seed beberapa aturan dasar untuk contoh
INSERT INTO file_access_rules (tag_name, role_name) VALUES
('keuangan', 'finance'),
('legal', 'legal'),
('laporan-bulanan', 'manager'),
('laporan-bulanan', 'admin');

COMMENT ON TABLE file_tags IS 'Associates files with descriptive tags for categorization and access control.';
COMMENT ON TABLE file_access_rules IS 'Defines which role has access to which file tag.';
