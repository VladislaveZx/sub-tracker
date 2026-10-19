--liquibase formatted sql
--changeset subtracker:001-create-tables
CREATE TABLE users (
                       id UUID PRIMARY KEY,
                       email VARCHAR(255) NOT NULL UNIQUE,
                       password_hash VARCHAR(255) NOT NULL,
                       base_currency VARCHAR(3) NOT NULL DEFAULT 'RUB',
                       telegram_chat_id BIGINT,
                       created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE categories (
                            id BIGSERIAL PRIMARY KEY,
                            name VARCHAR(100) NOT NULL UNIQUE,
                            icon VARCHAR(50)
);

CREATE TABLE subscriptions (
                               id UUID PRIMARY KEY,
                               user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                               category_id BIGINT REFERENCES categories(id) ON DELETE SET NULL,
                               title VARCHAR(150) NOT NULL,
                               price NUMERIC(12, 2) NOT NULL CHECK (price > 0),
                               currency VARCHAR(3) NOT NULL,
                               billing_cycle VARCHAR(20) NOT NULL,
                               next_payment_date DATE NOT NULL,
                               reminder_days_before INT NOT NULL DEFAULT 3 CHECK (reminder_days_before >= 0),
                               is_active BOOLEAN NOT NULL DEFAULT TRUE,
                               version BIGINT NOT NULL DEFAULT 0,
                               created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE payment_history (
                                 id UUID PRIMARY KEY,
                                 subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
                                 amount NUMERIC(12, 2) NOT NULL,
                                 currency VARCHAR(3) NOT NULL,
                                 paid_at DATE NOT NULL
);
CREATE INDEX idx_subscriptions_active_next_date ON subscriptions(is_active, next_payment_date);

--changeset subtracker:002-seed-categories
INSERT INTO categories (name, icon) VALUES
                                        ('Стриминги и кино', 'tv'),
                                        ('Музыка и подкасты', 'music'),
                                        ('Облачные сервисы и IT', 'cloud'),
                                        ('Спорт и здоровье', 'fitness'),
                                        ('Образование', 'book');
