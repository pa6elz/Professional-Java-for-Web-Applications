CREATE DATABASE CustomerSupport DEFAULT CHARACTER SET 'utf8'
  DEFAULT COLLATE 'utf8_unicode_ci';

USE CustomerSupport;

CREATE TABLE UserPrincipal (
  UserId BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  Username VARCHAR(30) NOT NULL,
  HashedPassword BINARY(60) NOT NULL,
  AccountNonExpired BOOLEAN NOT NULL,
  AccountNonLocked BOOLEAN NOT NULL,
  CredentialsNonExpired BOOLEAN NOT NULL,
  Enabled BOOLEAN NOT NULL,
  UNIQUE KEY UserPrincipal_Username (Username)
) ENGINE = InnoDB;

-- Run these statements if the UserPrincipal table doesn't contain these columns
-- ALTER TABLE UserPrincipal
--   ADD COLUMN AccountNonExpired BOOLEAN NOT NULL DEFAULT TRUE,
--   ADD COLUMN AccountNonLocked BOOLEAN NOT NULL DEFAULT TRUE,
--   ADD COLUMN CredentialsNonExpired BOOLEAN NOT NULL DEFAULT TRUE,
--   ADD COLUMN Enabled BOOLEAN NOT NULL DEFAULT TRUE;
-- ALTER TABLE UserPrincipal
--   MODIFY COLUMN AccountNonExpired BOOLEAN NOT NULL,
--   MODIFY COLUMN AccountNonLocked BOOLEAN NOT NULL,
--   MODIFY COLUMN CredentialsNonExpired BOOLEAN NOT NULL,
--   MODIFY COLUMN Enabled BOOLEAN NOT NULL;

CREATE TABLE UserPrincipal_Authority (
  UserId BIGINT UNSIGNED NOT NULL,
  Authority VARCHAR(100) NOT NULL,
  UNIQUE KEY UserPrincipal_Authority_User_Authority (UserId, Authority),
  CONSTRAINT UserPrincipal_Authority_UserId FOREIGN KEY (UserId)
    REFERENCES UserPrincipal (UserId) ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE Ticket (
  TicketId BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  UserId BIGINT UNSIGNED NOT NULL,
  Subject VARCHAR(255) NOT NULL,
  Body TEXT,
  DateCreated TIMESTAMP(6) NULL,
  CONSTRAINT Ticket_UserId FOREIGN KEY (UserId)
    REFERENCES UserPrincipal (UserId) ON DELETE CASCADE
) ENGINE = InnoDB;

ALTER TABLE Ticket ADD FULLTEXT INDEX Ticket_Search (Subject, Body);

CREATE TABLE TicketComment (
  CommentId BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  TicketId BIGINT UNSIGNED NOT NULL,
  UserId BIGINT UNSIGNED NOT NULL,
  Body TEXT,
  DateCreated TIMESTAMP(6) NULL,
  CONSTRAINT TicketComment_UserId FOREIGN KEY (UserId)
    REFERENCES UserPrincipal (UserId) ON DELETE CASCADE,
  CONSTRAINT TicketComment_TicketId FOREIGN KEY (TicketId)
    REFERENCES Ticket (TicketId) ON DELETE CASCADE
) ENGINE = InnoDB;

ALTER TABLE TicketComment ADD FULLTEXT INDEX TicketComment_Search (Body);

CREATE TABLE Attachment (
  AttachmentId BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  AttachmentName VARCHAR(255) NULL,
  MimeContentType VARCHAR(255) NOT NULL,
  Contents BLOB NOT NULL
) ENGINE = InnoDB;

CREATE TABLE Ticket_Attachment (
  SortKey SMALLINT NOT NULL,
  TicketId BIGINT UNSIGNED NOT NULL,
  AttachmentId BIGINT UNSIGNED NOT NULL,
  CONSTRAINT Ticket_Attachment_Ticket FOREIGN KEY (TicketId)
    REFERENCES Ticket (TicketId) ON DELETE CASCADE,
  CONSTRAINT Ticket_Attachment_Attachment FOREIGN KEY (AttachmentId)
    REFERENCES Attachment (AttachmentId) ON DELETE CASCADE,
  INDEX Ticket_OrderedAttachments (TicketId, SortKey, AttachmentId)
) ENGINE = InnoDB;

CREATE TABLE TicketComment_Attachment (
  SortKey SMALLINT NOT NULL,
  CommentId BIGINT UNSIGNED NOT NULL,
  AttachmentId BIGINT UNSIGNED NOT NULL,
  CONSTRAINT TicketComment_Attachment_Comment FOREIGN KEY (CommentId)
    REFERENCES TicketComment (CommentId) ON DELETE CASCADE,
  CONSTRAINT TicketComment_Attachment_Attachment FOREIGN KEY (AttachmentId)
    REFERENCES Attachment (AttachmentId) ON DELETE CASCADE,
  INDEX TicketComment_OrderedAttachments (CommentId, SortKey, AttachmentId)
) ENGINE = InnoDB;

-- Run these statements if the Attachment table already exists with a TicketId column
-- INSERT INTO Ticket_Attachment (SortKey, TicketId, AttachmentId)
--     SELECT @rn := @rn + 1, TicketId, AttachmentId
--         FROM Attachment, (SELECT @rn:=0) x
--         ORDER BY TicketId, AttachmentName;
-- CREATE TEMPORARY TABLE $minSortKeys ENGINE = Memory (
--   SELECT min(SortKey) as SortKey, TicketId FROM Ticket_Attachment GROUP BY TicketId
-- );
-- UPDATE Ticket_Attachment a SET a.SortKey = a.SortKey - (
--   SELECT x.SortKey FROM $minSortKeys x WHERE x.TicketId = a.TicketId
-- ) WHERE TicketId > 0;
-- DROP TABLE $minSortKeys;
-- ALTER TABLE Attachment DROP FOREIGN KEY Attachment_TicketId;
-- ALTER TABLE Attachment DROP COLUMN TicketId;

-- Run these statements to create the default users
INSERT INTO UserPrincipal (Username, HashedPassword, AccountNonExpired,
                           AccountNonLocked, CredentialsNonExpired, Enabled)
VALUES ( -- password
  'Nicholas', '$2a$10$x0k/yA5qN8SP8JD5CEN.6elEBFxVVHeKZTdyv.RPra4jzRR5SlKSC',
  TRUE, TRUE, TRUE, TRUE
);
INSERT INTO UserPrincipal_Authority (UserId, Authority)
  VALUES (1, 'VIEW_TICKETS'), (1, 'VIEW_TICKET'), (1, 'CREATE_TICKET'),
    (1, 'EDIT_OWN_TICKET'), (1, 'VIEW_COMMENTS'), (1, 'CREATE_COMMENT'),
    (1, 'EDIT_OWN_COMMENT'), (1, 'VIEW_ATTACHMENT'), (1, 'CREATE_CHAT_REQUEST'),
    (1, 'CHAT');

INSERT INTO UserPrincipal (Username, HashedPassword, AccountNonExpired,
                           AccountNonLocked, CredentialsNonExpired, Enabled)
VALUES ( -- drowssap
  'Sarah', '$2a$10$JSxmYO.JOb4TT42/4RFzguaTuYkZLCfeND1bB0rzoy7wH0RQFEq8y',
  TRUE, TRUE, TRUE, TRUE
);
INSERT INTO UserPrincipal_Authority (UserId, Authority)
  VALUES (2, 'VIEW_TICKETS'), (2, 'VIEW_TICKET'), (2, 'CREATE_TICKET'),
    (2, 'EDIT_OWN_TICKET'), (2, 'VIEW_COMMENTS'), (2, 'CREATE_COMMENT'),
    (2, 'EDIT_OWN_COMMENT'), (2, 'VIEW_ATTACHMENT'), (2, 'CREATE_CHAT_REQUEST'),
    (2, 'CHAT');

INSERT INTO UserPrincipal (Username, HashedPassword, AccountNonExpired,
                           AccountNonLocked, CredentialsNonExpired, Enabled)
VALUES ( -- wordpass
  'Mike', '$2a$10$Lc0W6stzND.9YnFRcfbOt.EaCVO9aJ/QpbWnfjJLcMovdTx5s4i3G',
  TRUE, TRUE, TRUE, TRUE
);
INSERT INTO UserPrincipal_Authority (UserId, Authority)
  VALUES (3, 'VIEW_TICKETS'), (3, 'VIEW_TICKET'), (3, 'CREATE_TICKET'),
    (3, 'EDIT_OWN_TICKET'), (3, 'VIEW_COMMENTS'), (3, 'CREATE_COMMENT'),
    (3, 'EDIT_OWN_COMMENT'), (3, 'VIEW_ATTACHMENT'), (3, 'CREATE_CHAT_REQUEST'),
    (3, 'CHAT');

INSERT INTO UserPrincipal (Username, HashedPassword, AccountNonExpired,
                           AccountNonLocked, CredentialsNonExpired, Enabled)
VALUES ( -- green
  'John', '$2a$10$vacuqbDw9I7rr6RRH8sByuktOzqTheQMfnK3XCT2WlaL7vt/3AMby',
  TRUE, TRUE, TRUE, TRUE
);
INSERT INTO UserPrincipal_Authority (UserId, Authority)
  VALUES (4, 'VIEW_TICKETS'), (4, 'VIEW_TICKET'), (4, 'CREATE_TICKET'),
    (4, 'EDIT_OWN_TICKET'), (4, 'VIEW_COMMENTS'), (4, 'CREATE_COMMENT'),
    (4, 'EDIT_OWN_COMMENT'), (4, 'VIEW_ATTACHMENT'), (4, 'CREATE_CHAT_REQUEST'),
    (4, 'CHAT'), (4, 'EDIT_ANY_TICKET'), (4, 'DELETE_TICKET'),
    (4, 'EDIT_ANY_COMMENT'), (4, 'DELETE_COMMENT'), (4, 'VIEW_USER_SESSIONS'),
    (4, 'VIEW_CHAT_REQUESTS'), (4, 'START_CHAT');
