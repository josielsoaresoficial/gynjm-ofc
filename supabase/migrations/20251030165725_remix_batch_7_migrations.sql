
-- Migration: 20251028194653
-- Criar tabela de perfis
CREATE TABLE public.profiles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE,
  name TEXT,
  avatar_url TEXT,
  age INTEGER,
  weight NUMERIC,
  height NUMERIC,
  fitness_goal TEXT,
  onboarding_completed BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para profiles
CREATE POLICY "Usuários podem ver seu próprio perfil" 
ON public.profiles 
FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar seu próprio perfil" 
ON public.profiles 
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seu próprio perfil" 
ON public.profiles 
FOR UPDATE 
USING (auth.uid() = user_id);

-- Criar tabela de refeições
CREATE TABLE public.meals (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  name TEXT NOT NULL,
  calories INTEGER,
  protein NUMERIC,
  carbs NUMERIC,
  fat NUMERIC,
  meal_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE public.meals ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para meals
CREATE POLICY "Usuários podem ver suas próprias refeições" 
ON public.meals 
FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar suas próprias refeições" 
ON public.meals 
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar suas próprias refeições" 
ON public.meals 
FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar suas próprias refeições" 
ON public.meals 
FOR DELETE 
USING (auth.uid() = user_id);

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- Trigger para profiles
CREATE TRIGGER update_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Trigger para meals
CREATE TRIGGER update_meals_updated_at
BEFORE UPDATE ON public.meals
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Trigger para criar perfil automaticamente ao criar usuário
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (user_id, name, avatar_url, onboarding_completed)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', NEW.raw_user_meta_data->>'picture'),
    false
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();

-- Migration: 20251029022157
-- Adicionar colunas para armazenar detalhes da análise de alimentos
ALTER TABLE public.meals 
ADD COLUMN IF NOT EXISTS foods_details JSONB,
ADD COLUMN IF NOT EXISTS is_estimated BOOLEAN DEFAULT false;

-- Migration: 20251029031100
-- Adicionar campo notes para descrição detalhada das análises de refeições
ALTER TABLE public.meals ADD COLUMN IF NOT EXISTS notes TEXT;

-- Migration: 20251029033834
-- Adicionar campos de metas nutricionais na tabela profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS daily_calories_goal integer DEFAULT 2200,
ADD COLUMN IF NOT EXISTS daily_protein_goal numeric DEFAULT 120,
ADD COLUMN IF NOT EXISTS daily_carbs_goal numeric DEFAULT 220,
ADD COLUMN IF NOT EXISTS daily_fat_goal numeric DEFAULT 60;

-- Migration: 20251029135233
-- Criar tabela de registros de calorias queimadas
CREATE TABLE public.calories_burned (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  calories INTEGER NOT NULL,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  activity_type TEXT,
  duration_minutes INTEGER,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.calories_burned ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Usuários podem ver seus próprios registros"
ON public.calories_burned
FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar seus próprios registros"
ON public.calories_burned
FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus próprios registros"
ON public.calories_burned
FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar seus próprios registros"
ON public.calories_burned
FOR DELETE
USING (auth.uid() = user_id);

-- Adicionar campos de meta de calorias no perfil
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS daily_calories_burn_goal INTEGER DEFAULT 500;

-- Trigger para atualizar updated_at
CREATE TRIGGER update_calories_burned_updated_at
BEFORE UPDATE ON public.calories_burned
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Índice para melhor performance
CREATE INDEX idx_calories_burned_user_date ON public.calories_burned(user_id, date DESC);

-- Migration: 20251029141529
-- Tabela de exercícios
CREATE TABLE public.exercises (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  video_url TEXT,
  gif_url TEXT,
  muscle_groups TEXT[] NOT NULL,
  difficulty TEXT NOT NULL CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  equipment_needed TEXT[],
  calories_per_minute NUMERIC DEFAULT 10,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Tabela de treinos
CREATE TABLE public.workouts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL CHECK (category IN ('full_body', 'abs', 'hiit', 'strength', 'legs', 'back', 'cardio', '7_minute')),
  duration_minutes INTEGER NOT NULL,
  estimated_calories INTEGER NOT NULL,
  difficulty TEXT NOT NULL CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  exercises_data JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Tabela de histórico de treinos
CREATE TABLE public.workout_history (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  workout_id UUID REFERENCES public.workouts(id),
  completed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  duration_seconds INTEGER NOT NULL,
  calories_burned INTEGER NOT NULL,
  exercises_completed INTEGER NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_history ENABLE ROW LEVEL SECURITY;

-- RLS Policies para exercises (público para leitura)
CREATE POLICY "Todos podem ver exercícios"
ON public.exercises FOR SELECT
USING (true);

-- RLS Policies para workouts (público para leitura)
CREATE POLICY "Todos podem ver treinos"
ON public.workouts FOR SELECT
USING (true);

-- RLS Policies para workout_history
CREATE POLICY "Usuários podem ver seu próprio histórico"
ON public.workout_history FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar seu próprio histórico"
ON public.workout_history FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seu próprio histórico"
ON public.workout_history FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar seu próprio histórico"
ON public.workout_history FOR DELETE
USING (auth.uid() = user_id);

-- Triggers para updated_at
CREATE TRIGGER update_exercises_updated_at
BEFORE UPDATE ON public.exercises
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_workouts_updated_at
BEFORE UPDATE ON public.workouts
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Inserir dados iniciais de treinos
INSERT INTO public.workouts (name, description, category, duration_minutes, estimated_calories, difficulty, exercises_data) VALUES
('Treino 7 Minutos', 'Circuito rápido e eficiente para o corpo inteiro', '7_minute', 7, 80, 'beginner', 
'[{"name":"Jumping Jacks","duration":30,"rest":10},{"name":"Wall Sit","duration":30,"rest":10},{"name":"Push-ups","duration":30,"rest":10},{"name":"Crunches","duration":30,"rest":10},{"name":"Step-ups","duration":30,"rest":10},{"name":"Squats","duration":30,"rest":10},{"name":"Tricep Dips","duration":30,"rest":10},{"name":"Plank","duration":30,"rest":10},{"name":"High Knees","duration":30,"rest":10},{"name":"Lunges","duration":30,"rest":10},{"name":"Push-up Rotation","duration":30,"rest":10},{"name":"Side Plank","duration":30,"rest":10}]'::jsonb),

('Full Body Completo', 'Treino balanceado para corpo inteiro com 15 exercícios', 'full_body', 30, 250, 'intermediate',
'[{"name":"Burpees","duration":45,"rest":15},{"name":"Mountain Climbers","duration":45,"rest":15},{"name":"Push-ups","duration":45,"rest":15},{"name":"Squats","duration":45,"rest":15},{"name":"Plank","duration":60,"rest":15},{"name":"Lunges","duration":45,"rest":15},{"name":"Tricep Dips","duration":45,"rest":15},{"name":"Bicycle Crunches","duration":45,"rest":15},{"name":"Jump Squats","duration":45,"rest":15},{"name":"Superman","duration":45,"rest":15},{"name":"High Knees","duration":45,"rest":15},{"name":"Russian Twists","duration":45,"rest":15},{"name":"Wall Sit","duration":60,"rest":15},{"name":"Pike Push-ups","duration":45,"rest":15},{"name":"Jumping Jacks","duration":45,"rest":15}]'::jsonb),

('Abdômen Intenso', 'Foco em core e estabilização com 14 exercícios', 'abs', 25, 180, 'intermediate',
'[{"name":"Crunches","duration":45,"rest":15},{"name":"Plank","duration":60,"rest":15},{"name":"Bicycle Crunches","duration":45,"rest":15},{"name":"Russian Twists","duration":45,"rest":15},{"name":"Leg Raises","duration":45,"rest":15},{"name":"Mountain Climbers","duration":45,"rest":15},{"name":"Side Plank L","duration":45,"rest":15},{"name":"Side Plank R","duration":45,"rest":15},{"name":"Flutter Kicks","duration":45,"rest":15},{"name":"V-ups","duration":45,"rest":15},{"name":"Dead Bug","duration":45,"rest":15},{"name":"Hollow Hold","duration":45,"rest":15},{"name":"Reverse Crunches","duration":45,"rest":15},{"name":"Plank Jacks","duration":45,"rest":15}]'::jsonb),

('HIIT Intenso', 'Sistema de intervalos de alta intensidade', 'hiit', 15, 200, 'intermediate',
'[{"name":"Burpees","duration":30,"rest":10},{"name":"High Knees","duration":30,"rest":10},{"name":"Jump Squats","duration":30,"rest":10},{"name":"Mountain Climbers","duration":30,"rest":10},{"name":"Jumping Jacks","duration":30,"rest":10},{"name":"Sprint in Place","duration":30,"rest":10},{"name":"Box Jumps","duration":30,"rest":10},{"name":"Skater Jumps","duration":30,"rest":10},{"name":"Plank Jacks","duration":30,"rest":10},{"name":"Tuck Jumps","duration":30,"rest":10}]'::jsonb),

('Força Total', 'Treino completo com foco em força', 'strength', 45, 350, 'advanced',
'[{"name":"Push-ups","duration":60,"rest":20},{"name":"Squats","duration":60,"rest":20},{"name":"Pull-ups","duration":60,"rest":20},{"name":"Deadlift Position","duration":60,"rest":20},{"name":"Pike Push-ups","duration":60,"rest":20},{"name":"Bulgarian Squats","duration":60,"rest":20},{"name":"Tricep Dips","duration":60,"rest":20},{"name":"Lunges","duration":60,"rest":20},{"name":"Plank","duration":90,"rest":20},{"name":"Diamond Push-ups","duration":60,"rest":20}]'::jsonb),

('Pernas Completo', 'Treino focado em membros inferiores', 'legs', 35, 280, 'intermediate',
'[{"name":"Squats","duration":60,"rest":15},{"name":"Lunges","duration":60,"rest":15},{"name":"Jump Squats","duration":45,"rest":15},{"name":"Wall Sit","duration":60,"rest":15},{"name":"Calf Raises","duration":45,"rest":15},{"name":"Bulgarian Squats L","duration":45,"rest":15},{"name":"Bulgarian Squats R","duration":45,"rest":15},{"name":"Side Lunges","duration":45,"rest":15},{"name":"Glute Bridges","duration":60,"rest":15},{"name":"Step-ups","duration":45,"rest":15},{"name":"Sumo Squats","duration":60,"rest":15},{"name":"Single Leg Deadlift L","duration":45,"rest":15},{"name":"Single Leg Deadlift R","duration":45,"rest":15},{"name":"Box Jumps","duration":45,"rest":15},{"name":"Squat Pulses","duration":45,"rest":15},{"name":"Leg Raises","duration":45,"rest":15},{"name":"Fire Hydrants L","duration":45,"rest":15},{"name":"Fire Hydrants R","duration":45,"rest":15}]'::jsonb),

('Costas e Postura', 'Fortalecimento das costas e melhora postural', 'back', 30, 220, 'intermediate',
'[{"name":"Superman","duration":45,"rest":15},{"name":"Reverse Snow Angels","duration":45,"rest":15},{"name":"Pull-ups","duration":45,"rest":15},{"name":"Bent Over Rows","duration":60,"rest":15},{"name":"Plank","duration":60,"rest":15},{"name":"Bird Dog L","duration":45,"rest":15},{"name":"Bird Dog R","duration":45,"rest":15},{"name":"Lat Pulldown Position","duration":45,"rest":15},{"name":"Back Extensions","duration":45,"rest":15},{"name":"Y-raises","duration":45,"rest":15},{"name":"T-raises","duration":45,"rest":15},{"name":"W-raises","duration":45,"rest":15},{"name":"Prone Cobra","duration":45,"rest":15},{"name":"Reverse Plank","duration":45,"rest":15},{"name":"Scapular Push-ups","duration":45,"rest":15},{"name":"Dead Hang","duration":30,"rest":15}]'::jsonb),

('Cardio Explosivo', 'Alta intensidade cardiovascular', 'cardio', 20, 250, 'intermediate',
'[{"name":"Jumping Jacks","duration":60,"rest":10},{"name":"High Knees","duration":60,"rest":10},{"name":"Burpees","duration":45,"rest":10},{"name":"Mountain Climbers","duration":60,"rest":10},{"name":"Sprint in Place","duration":60,"rest":10},{"name":"Jump Rope","duration":60,"rest":10},{"name":"Skater Jumps","duration":45,"rest":10},{"name":"Box Jumps","duration":45,"rest":10},{"name":"Butt Kickers","duration":60,"rest":10},{"name":"Tuck Jumps","duration":45,"rest":10}]'::jsonb);

-- Migration: 20251029155015
-- Tabela para evolução de força em exercícios
CREATE TABLE public.progress_strength (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  exercise_name TEXT NOT NULL,
  current_weight NUMERIC NOT NULL,
  target_weight NUMERIC NOT NULL,
  initial_weight NUMERIC NOT NULL,
  unit TEXT NOT NULL DEFAULT 'kg',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Tabela para métricas corporais
CREATE TABLE public.body_metrics (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  weight NUMERIC,
  body_fat_percentage NUMERIC,
  muscle_mass NUMERIC,
  bmi NUMERIC,
  measurement_date DATE NOT NULL DEFAULT CURRENT_DATE,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Tabela para conquistas/achievements
CREATE TABLE public.user_achievements (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  achievement_id TEXT NOT NULL,
  achievement_name TEXT NOT NULL,
  achievement_description TEXT NOT NULL,
  points INTEGER NOT NULL DEFAULT 0,
  completed BOOLEAN NOT NULL DEFAULT false,
  progress_current INTEGER DEFAULT 0,
  progress_target INTEGER DEFAULT 100,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(user_id, achievement_id)
);

-- Tabela para metas do usuário
CREATE TABLE public.user_goals (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  goal_type TEXT NOT NULL, -- 'weight', 'strength', 'cardio', etc
  goal_name TEXT NOT NULL,
  current_value NUMERIC NOT NULL,
  target_value NUMERIC NOT NULL,
  unit TEXT NOT NULL,
  deadline DATE,
  completed BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.progress_strength ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.body_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_goals ENABLE ROW LEVEL SECURITY;

-- RLS Policies para progress_strength
CREATE POLICY "Usuários podem ver seu próprio progresso de força"
ON public.progress_strength FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar seu próprio progresso de força"
ON public.progress_strength FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seu próprio progresso de força"
ON public.progress_strength FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar seu próprio progresso de força"
ON public.progress_strength FOR DELETE
USING (auth.uid() = user_id);

-- RLS Policies para body_metrics
CREATE POLICY "Usuários podem ver suas próprias métricas"
ON public.body_metrics FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar suas próprias métricas"
ON public.body_metrics FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar suas próprias métricas"
ON public.body_metrics FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar suas próprias métricas"
ON public.body_metrics FOR DELETE
USING (auth.uid() = user_id);

-- RLS Policies para user_achievements
CREATE POLICY "Usuários podem ver suas próprias conquistas"
ON public.user_achievements FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar suas próprias conquistas"
ON public.user_achievements FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar suas próprias conquistas"
ON public.user_achievements FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar suas próprias conquistas"
ON public.user_achievements FOR DELETE
USING (auth.uid() = user_id);

-- RLS Policies para user_goals
CREATE POLICY "Usuários podem ver suas próprias metas"
ON public.user_goals FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar suas próprias metas"
ON public.user_goals FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar suas próprias metas"
ON public.user_goals FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar suas próprias metas"
ON public.user_goals FOR DELETE
USING (auth.uid() = user_id);

-- Trigger para atualizar updated_at
CREATE TRIGGER update_progress_strength_updated_at
BEFORE UPDATE ON public.progress_strength
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_goals_updated_at
BEFORE UPDATE ON public.user_goals
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();
