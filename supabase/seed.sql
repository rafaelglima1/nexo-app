-- NEXO - Seed Data de Teste (Schema 002 - Server)
-- Execute no Supabase SQL Editor APÓS rodar 002_server_schema.sql

-- ============================================
-- 1. CRIAR USUÁRIOS DE TESTE (tabela users)
-- ============================================
-- Usuários do app (não auth.users - auth é gerenciado pelo Supabase)

-- Usuário 1: Ana
INSERT INTO users (id, email, password_hash, name, personality, experience_type, is_verified, created_at)
VALUES (
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  'ana@nexo.com',
  crypt('senha123', gen_salt('bf')),
  'Ana Silva',
  'introvertida',
  'aventureira',
  true,
  NOW() - INTERVAL '30 days'
) ON CONFLICT (id) DO NOTHING;

-- Usuário 2: Bruno
INSERT INTO users (id, email, password_hash, name, personality, experience_type, is_verified, created_at)
VALUES (
  'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
  'bruno@nexo.com',
  crypt('senha123', gen_salt('bf')),
  'Bruno Costa',
  'extrovertido',
  'social',
  true,
  NOW() - INTERVAL '25 days'
) ON CONFLICT (id) DO NOTHING;

-- Usuário 3: Carla
INSERT INTO users (id, email, password_hash, name, personality, experience_type, is_verified, created_at)
VALUES (
  'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33',
  'carla@nexo.com',
  crypt('senha123', gen_salt('bf')),
  'Carla Mendes',
  'calma',
  'reflexiva',
  false,
  NOW() - INTERVAL '20 days'
) ON CONFLICT (id) DO NOTHING;

-- Usuário 4: Daniel
INSERT INTO users (id, email, password_hash, name, personality, experience_type, is_verified, created_at)
VALUES (
  'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44',
  'daniel@nexo.com',
  crypt('senha123', gen_salt('bf')),
  'Daniel Oliveira',
  'aventureiro',
  'criativo',
  true,
  NOW() - INTERVAL '15 days'
) ON CONFLICT (id) DO NOTHING;

-- Usuário 5: Elena
INSERT INTO users (id, email, password_hash, name, personality, experience_type, is_verified, created_at)
VALUES (
  'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55',
  'elena@nexo.com',
  crypt('senha123', gen_salt('bf')),
  'Elena Santos',
  'animada',
  'expressiva',
  false,
  NOW() - INTERVAL '10 days'
) ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 2. INTERESTS
-- ============================================
INSERT INTO interests (id, name) VALUES
  ('música', 'Música'),
  ('cinema', 'Cinema'),
  ('culinária', 'Culinária'),
  ('jogos', 'Jogos'),
  ('tecnologia', 'Tecnologia'),
  ('esportes', 'Esportes'),
  ('livros', 'Livros'),
  ('yoga', 'Yoga'),
  ('natureza', 'Natureza'),
  ('viagens', 'Viagens'),
  ('fotografia', 'Fotografia'),
  ('dança', 'Dança'),
  ('teatro', 'Teatro'),
  ('arte', 'Arte'),
  ('séries', 'Séries'),
  ('café', 'Café'),
  ('aventura', 'Aventura'),
  ('programação', 'Programação'),
  ('bem-estar', 'Bem-estar'),
  ('shows', 'Shows'),
  ('composição', 'Composição')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 3. USER INTERESTS
-- ============================================
INSERT INTO user_interests (user_id, interest_id) VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'música'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'cinema'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'culinária'),
  ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'jogos'),
  ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'tecnologia'),
  ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'esportes'),
  ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'livros'),
  ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'yoga'),
  ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'natureza'),
  ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', 'música'),
  ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', 'viagens'),
  ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', 'fotografia'),
  ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55', 'dança'),
  ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55', 'teatro'),
  ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55', 'arte')
ON CONFLICT DO NOTHING;

-- ============================================
-- 4. COMUNIDADES
-- ============================================
INSERT INTO communities (id, name, description, created_at)
VALUES
  ('10eebc99-9c0b-4ef8-bb6d-6bb9bd380b01', 'Cinefilos Unidos',
   'Comunidade para amantes de cinema e séries',
   NOW() - INTERVAL '20 days'),
  ('20eebc99-9c0b-4ef8-bb6d-6bb9bd380b02', 'Mochilas e Cafés',
   'Viajantes que adoram um bom café pelo caminho',
   NOW() - INTERVAL '15 days'),
  ('30eebc99-9c0b-4ef8-bb6d-6bb9bd380b03', 'Code & Coffee',
   'Programadores que precisam de pausas saudáveis',
   NOW() - INTERVAL '10 days'),
  ('40eebc99-9c0b-4ef8-bb6d-6bb9bd380b04', 'Alma Música',
   'Discussões sobre música, shows e descobertas sonoras',
   NOW() - INTERVAL '5 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 5. COMMUNITY INTERESTS
-- ============================================
INSERT INTO community_interests (community_id, interest_id) VALUES
  ('10eebc99-9c0b-4ef8-bb6d-6bb9bd380b01', 'cinema'),
  ('10eebc99-9c0b-4ef8-bb6d-6bb9bd380b01', 'séries'),
  ('20eebc99-9c0b-4ef8-bb6d-6bb9bd380b02', 'viagens'),
  ('20eebc99-9c0b-4ef8-bb6d-6bb9bd380b02', 'café'),
  ('20eebc99-9c0b-4ef8-bb6d-6bb9bd380b02', 'aventura'),
  ('30eebc99-9c0b-4ef8-bb6d-6bb9bd380b03', 'tecnologia'),
  ('30eebc99-9c0b-4ef8-bb6d-6bb9bd380b03', 'programação'),
  ('30eebc99-9c0b-4ef8-bb6d-6bb9bd380b03', 'bem-estar'),
  ('40eebc99-9c0b-4ef8-bb6d-6bb9bd380b04', 'música'),
  ('40eebc99-9c0b-4ef8-bb6d-6bb9bd380b04', 'shows'),
  ('40eebc99-9c0b-4ef8-bb6d-6bb9bd380b04', 'composição')
ON CONFLICT DO NOTHING;

-- ============================================
-- 4. MEMBROS DAS COMUNIDADES
-- ============================================
INSERT INTO community_members (community_id, user_id, role)
VALUES
  -- Cinefilos Unidos
  ('10eebc99-9c0b-4ef8-bb6d-6bb9bd380b01', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'admin'),
  ('10eebc99-9c0b-4ef8-bb6d-6bb9bd380b01', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'member'),
  ('10eebc99-9c0b-4ef8-bb6d-6bb9bd380b01', 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', 'member'),
  -- Mochilas e Cafés
  ('20eebc99-9c0b-4ef8-bb6d-6bb9bd380b02', 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', 'admin'),
  ('20eebc99-9c0b-4ef8-bb6d-6bb9bd380b02', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'member'),
  -- Code & Coffee
  ('30eebc99-9c0b-4ef8-bb6d-6bb9bd380b03', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'admin'),
  ('30eebc99-9c0b-4ef8-bb6d-6bb9bd380b03', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55', 'member'),
  -- Alma Música
  ('40eebc99-9c0b-4ef8-bb6d-6bb9bd380b04', 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', 'admin'),
  ('40eebc99-9c0b-4ef8-bb6d-6bb9bd380b04', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'member'),
  ('40eebc99-9c0b-4ef8-bb6d-6bb9bd380b04', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55', 'member')
ON CONFLICT DO NOTHING;

-- ============================================
-- 5. SALAS DE VÍDEO/ÁUDIO
-- ============================================
INSERT INTO rooms (id, title, description, category, host_id, max_participants, is_live, guided_questions, created_at)
VALUES
  ('50eebc99-9c0b-4ef8-bb6d-6bb9bd380c01', 'Café da Noite',
   'Conversa descontraída sobre o dia', 'cafe',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 8, true,
   ARRAY['Qual foi a melhor parte do seu dia?', 'O que te fez sorrir hoje?'],
   NOW() - INTERVAL '2 hours'),
  ('50eebc99-9c0b-4ef8-bb6d-6bb9bd380c02', 'Sessão Cinema Domingo',
   'Assistimos um filme juntos e comentamos', 'filmes',
   'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 6, false,
   ARRAY['Qual filme vocês querem assistir?', 'Já viram esse filme antes?'],
   NOW() - INTERVAL '1 day'),
  ('50eebc99-9c0b-4ef8-bb6d-6bb9bd380c03', 'Jam Session',
   'Tocamos e cantamos juntos', 'musica',
   'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', 10, true,
   ARRAY['Qual música toca seu coração?', 'Tocam algum instrumento?'],
   NOW() - INTERVAL '1 hour'),
  ('50eebc99-9c0b-4ef8-bb6d-6bb9bd380c04', 'Roda de Conversa',
   'Tópicos profundos e significativos', 'conversas',
   'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 6, false,
   ARRAY['Qual lição de vida você aprendeu recentemente?', 'O que significa conexão pra você?'],
   NOW() - INTERVAL '3 hours')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 6. PARTICIPANTES DAS SALAS
-- ============================================
INSERT INTO room_participants (room_id, user_id)
VALUES
  -- Café da Noite (ao vivo)
  ('50eebc99-9c0b-4ef8-bb6d-6bb9bd380c01', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'),
  ('50eebc99-9c0b-4ef8-bb6d-6bb9bd380c01', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22'),
  ('50eebc99-9c0b-4ef8-bb6d-6bb9bd380c01', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55'),
  -- Jam Session (ao vivo)
  ('50eebc99-9c0b-4ef8-bb6d-6bb9bd380c03', 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44'),
  ('50eebc99-9c0b-4ef8-bb6d-6bb9bd380c03', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'),
  ('50eebc99-9c0b-4ef8-bb6d-6bb9bd380c03', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55')
ON CONFLICT DO NOTHING;

-- ============================================
-- 7. EVENTOS
-- ============================================
INSERT INTO events (id, title, description, event_date, is_seasonal, created_at)
VALUES
  ('60eebc99-9c0b-4ef8-bb6d-6bb9bd380d01', 'Festa Junina Online',
   'Celebração junina com quadrilha virtual, comidas típicas e música ao vivo',
   NOW() + INTERVAL '7 days', true, NOW() - INTERVAL '5 days'),
  ('60eebc99-9c0b-4ef8-bb6d-6bb9bd380d02', 'Noite de Filmes',
   'Sessão maratona de filmes clássicos do cinema brasileiro',
   NOW() + INTERVAL '3 days', false, NOW() - INTERVAL '2 days'),
  ('60eebc99-9c0b-4ef8-bb6d-6bb9bd380d03', 'Work-life Balance',
   'Workshop sobre equilíbrio entre vida pessoal e profissional',
   NOW() + INTERVAL '10 days', false, NOW() - INTERVAL '1 day'),
  ('60eebc99-9c0b-4ef8-bb6d-6bb9bd380d04', 'Natal sem Solidão',
   'Evento especial de Natal para quem está longe de casa',
   '2025-12-25 20:00:00+00', true, NOW() - INTERVAL '30 days')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 8. PARTICIPANTES DOS EVENTOS
-- ============================================
INSERT INTO event_participants (event_id, user_id)
VALUES
  -- Festa Junina
  ('60eebc99-9c0b-4ef8-bb6d-6bb9bd380d01', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'),
  ('60eebc99-9c0b-4ef8-bb6d-6bb9bd380d01', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22'),
  ('60eebc99-9c0b-4ef8-bb6d-6bb9bd380d01', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33'),
  ('60eebc99-9c0b-4ef8-bb6d-6bb9bd380d01', 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44'),
  ('60eebc99-9c0b-4ef8-bb6d-6bb9bd380d01', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55'),
  -- Noite de Filmes
  ('60eebc99-9c0b-4ef8-bb6d-6bb9bd380d02', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'),
  ('60eebc99-9c0b-4ef8-bb6d-6bb9bd380d02', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33'),
  -- Workshop
  ('60eebc99-9c0b-4ef8-bb6d-6bb9bd380d03', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22')
ON CONFLICT DO NOTHING;

-- ============================================
-- 9. CONVERSAS E MENSAGENS
-- ============================================
-- Conversa entre Ana e Bruno
INSERT INTO conversations (id, name, is_group, created_at)
VALUES ('70eebc99-9c0b-4ef8-bb6d-6bb9bd380e01', NULL, false, NOW() - INTERVAL '5 days')
ON CONFLICT (id) DO NOTHING;

INSERT INTO conversation_participants (conversation_id, user_id)
VALUES
  ('70eebc99-9c0b-4ef8-bb6d-6bb9bd380e01', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'),
  ('70eebc99-9c0b-4ef8-bb6d-6bb9bd380e01', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22')
ON CONFLICT DO NOTHING;

INSERT INTO messages (conversation_id, sender_id, content, created_at)
VALUES
  ('70eebc99-9c0b-4ef8-bb6d-6bb9bd380e01', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
   'Oi! Vi que você também gosta de cinema. Já viu aquele novo do Wes Anderson?', NOW() - INTERVAL '5 days'),
  ('70eebc99-9c0b-4ef8-bb6d-6bb9bd380e01', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
   'Sim! Amei a estética como sempre. Quer assistir junto na sala?', NOW() - INTERVAL '5 days' + INTERVAL '30 minutes'),
  ('70eebc99-9c0b-4ef8-bb6d-6bb9bd380e01', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
   'Bora! Eu crio a sala depois. Qual dia fica melhor pra você?', NOW() - INTERVAL '5 days' + INTERVAL '1 hour'),
  ('70eebc99-9c0b-4ef8-bb6d-6bb9bd380e01', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
   'Domingo à noite seria perfeito!', NOW() - INTERVAL '5 days' + INTERVAL '2 hours');

-- Conversa em grupo: Code & Coffee
INSERT INTO conversations (id, name, is_group, created_at)
VALUES ('70eebc99-9c0b-4ef8-bb6d-6bb9bd380e02', 'Code & Coffee - Geral', true, NOW() - INTERVAL '3 days')
ON CONFLICT (id) DO NOTHING;

INSERT INTO conversation_participants (conversation_id, user_id)
VALUES
  ('70eebc99-9c0b-4ef8-bb6d-6bb9bd380e02', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22'),
  ('70eebc99-9c0b-4ef8-bb6d-6bb9bd380e02', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55')
ON CONFLICT DO NOTHING;

INSERT INTO messages (conversation_id, sender_id, content, created_at)
VALUES
  ('70eebc99-9c0b-4ef8-bb6d-6bb9bd380e02', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
   'Pessoal, quem vai no workshop de amanhã?', NOW() - INTERVAL '3 days'),
  ('70eebc99-9c0b-4ef8-bb6d-6bb9bd380e02', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55',
   'Eu vou! Preciso muito de dicas de equilíbrio', NOW() - INTERVAL '3 days' + INTERVAL '1 hour'),
  ('70eebc99-9c0b-4ef8-bb6d-6bb9bd380e02', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
   'Vamos combination! Depois tomamos um café virtual', NOW() - INTERVAL '3 days' + INTERVAL '2 hours');

-- ============================================
-- 10. NOTIFICAÇÕES
-- ============================================
INSERT INTO notifications (user_id, title, body, type, is_read, created_at)
VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Café da Noite',
   'Começa em 30 minutos! Participe da conversa.', 'event', false, NOW() - INTERVAL '30 minutes'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Novo evento: Festa Junina Online',
   '24 de Junho, 20:00. Não perca!', 'event', true, NOW() - INTERVAL '2 days'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Bruno está online',
   'Seu amigo está em uma sala. Diz oi!', 'friend', false, NOW()),
  ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Sala recomendada: Cinema de Domingo',
   'Baseado nos seus interesses em filmes.', 'recommendation', false, NOW()),
  ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Ana te enviou uma mensagem',
   'Confira a conversa de vocês', 'social', true, NOW() - INTERVAL '1 day'),
  ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55', 'Natal sem Solidão',
   'Evento especial em 25/12. Reserve sua vaga!', 'seasonal', false, NOW() - INTERVAL '5 days'),
  ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55', 'Workshop: Work-life Balance',
   'Inscrições abertas! Vagas limitadas.', 'event', false, NOW() - INTERVAL '1 day')
ON CONFLICT DO NOTHING;

-- ============================================
-- RESUMO
-- ============================================
SELECT 'Seed data inserido com sucesso!' as status;
SELECT COUNT(*) as total_usuarios FROM users;
SELECT COUNT(*) as total_interesses FROM interests;
SELECT COUNT(*) as total_comunidades FROM communities;
SELECT COUNT(*) as total_salas FROM rooms;
SELECT COUNT(*) as total_eventos FROM events;
SELECT COUNT(*) as total_mensagens FROM messages;
SELECT COUNT(*) as total_notificacoes FROM notifications;
