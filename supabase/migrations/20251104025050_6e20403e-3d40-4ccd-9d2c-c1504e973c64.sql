-- Create recipes table
CREATE TABLE public.recipes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  difficulty TEXT NOT NULL DEFAULT 'medium',
  prep_time_minutes INTEGER NOT NULL,
  cook_time_minutes INTEGER NOT NULL,
  servings INTEGER NOT NULL DEFAULT 1,
  calories INTEGER NOT NULL,
  protein NUMERIC NOT NULL,
  carbs NUMERIC NOT NULL,
  fat NUMERIC NOT NULL,
  ingredients JSONB NOT NULL,
  instructions JSONB NOT NULL,
  tags TEXT[],
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;

-- Create policy for viewing recipes
CREATE POLICY "Todos podem ver receitas"
ON public.recipes
FOR SELECT
USING (true);

-- Create trigger for automatic timestamp updates
CREATE TRIGGER update_recipes_updated_at
BEFORE UPDATE ON public.recipes
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Insert sample recipes
INSERT INTO public.recipes (name, description, category, difficulty, prep_time_minutes, cook_time_minutes, servings, calories, protein, carbs, fat, ingredients, instructions, tags) VALUES
('Salada Proteica', 'Perfeita para atingir sua meta de proteína', 'Saladas', 'easy', 10, 0, 1, 380, 35, 20, 15, 
'[{"item": "Peito de frango grelhado", "quantity": "150g"}, {"item": "Folhas verdes mistas", "quantity": "100g"}, {"item": "Tomate cereja", "quantity": "50g"}, {"item": "Pepino", "quantity": "50g"}, {"item": "Queijo cottage", "quantity": "50g"}, {"item": "Azeite de oliva", "quantity": "1 colher de sopa"}]'::jsonb,
'[{"step": 1, "description": "Corte o frango grelhado em cubos"}, {"step": 2, "description": "Lave e seque as folhas verdes"}, {"step": 3, "description": "Corte os tomates cereja ao meio e o pepino em rodelas"}, {"step": 4, "description": "Monte a salada em uma tigela grande"}, {"step": 5, "description": "Adicione o queijo cottage por cima"}, {"step": 6, "description": "Regue com azeite de oliva e temperos a gosto"}]'::jsonb,
ARRAY['proteína', 'baixo carb', 'saudável']),

('Smoothie Pós-Treino', 'Ideal para recuperação muscular', 'Bebidas', 'easy', 5, 0, 1, 320, 28, 35, 8,
'[{"item": "Whey protein (sabor baunilha)", "quantity": "30g"}, {"item": "Banana", "quantity": "1 unidade"}, {"item": "Leite desnatado", "quantity": "200ml"}, {"item": "Aveia", "quantity": "2 colheres de sopa"}, {"item": "Mel", "quantity": "1 colher de chá"}, {"item": "Gelo", "quantity": "4 cubos"}]'::jsonb,
'[{"step": 1, "description": "Adicione o leite no liquidificador"}, {"step": 2, "description": "Acrescente a banana cortada em rodelas"}, {"step": 3, "description": "Adicione o whey protein e a aveia"}, {"step": 4, "description": "Coloque o mel e o gelo"}, {"step": 5, "description": "Bata por 1 minuto até ficar homogêneo"}, {"step": 6, "description": "Sirva imediatamente"}]'::jsonb,
ARRAY['proteína', 'pós-treino', 'rápido']),

('Salmão Grelhado', 'Rico em ômega-3 e proteínas', 'Pratos Principais', 'medium', 10, 15, 1, 420, 38, 10, 22,
'[{"item": "Filé de salmão", "quantity": "180g"}, {"item": "Brócolis", "quantity": "150g"}, {"item": "Batata doce", "quantity": "100g"}, {"item": "Limão", "quantity": "1/2 unidade"}, {"item": "Alho", "quantity": "2 dentes"}, {"item": "Azeite", "quantity": "1 colher de sopa"}, {"item": "Sal e pimenta", "quantity": "a gosto"}]'::jsonb,
'[{"step": 1, "description": "Tempere o salmão com sal, pimenta, alho picado e suco de limão"}, {"step": 2, "description": "Deixe marinar por 10 minutos"}, {"step": 3, "description": "Cozinhe a batata doce no vapor por 15 minutos"}, {"step": 4, "description": "Cozinhe o brócolis no vapor por 5 minutos"}, {"step": 5, "description": "Grelhe o salmão em uma frigideira com azeite por 4 minutos de cada lado"}, {"step": 6, "description": "Sirva o salmão com os vegetais"}]'::jsonb,
ARRAY['proteína', 'ômega-3', 'saudável']),

('Omelete de Claras', 'Rica em proteínas e baixa em calorias', 'Café da Manhã', 'easy', 5, 10, 1, 180, 24, 8, 5,
'[{"item": "Claras de ovo", "quantity": "4 unidades"}, {"item": "Espinafre", "quantity": "50g"}, {"item": "Tomate", "quantity": "50g"}, {"item": "Queijo branco", "quantity": "30g"}, {"item": "Cebola", "quantity": "1/4 unidade"}, {"item": "Azeite", "quantity": "1 colher de chá"}]'::jsonb,
'[{"step": 1, "description": "Bata as claras em uma tigela"}, {"step": 2, "description": "Pique o espinafre, tomate e cebola"}, {"step": 3, "description": "Aqueça o azeite em uma frigideira antiaderente"}, {"step": 4, "description": "Refogue a cebola e o espinafre por 2 minutos"}, {"step": 5, "description": "Despeje as claras batidas na frigideira"}, {"step": 6, "description": "Adicione o tomate e o queijo branco"}, {"step": 7, "description": "Cozinhe por 3-4 minutos até firmar"}, {"step": 8, "description": "Dobre ao meio e sirva"}]'::jsonb,
ARRAY['proteína', 'baixa caloria', 'café da manhã']),

('Frango com Batata Doce', 'Clássico para ganho de massa muscular', 'Pratos Principais', 'easy', 15, 25, 2, 450, 42, 45, 10,
'[{"item": "Peito de frango", "quantity": "200g"}, {"item": "Batata doce", "quantity": "200g"}, {"item": "Brócolis", "quantity": "100g"}, {"item": "Alho", "quantity": "3 dentes"}, {"item": "Cebola", "quantity": "1/2 unidade"}, {"item": "Azeite", "quantity": "1 colher de sopa"}, {"item": "Temperos naturais", "quantity": "a gosto"}]'::jsonb,
'[{"step": 1, "description": "Tempere o frango com alho, sal e pimenta"}, {"step": 2, "description": "Corte a batata doce em cubos"}, {"step": 3, "description": "Asse a batata doce no forno a 200°C por 25 minutos"}, {"step": 4, "description": "Grelhe o frango em uma frigideira com azeite"}, {"step": 5, "description": "Cozinhe o brócolis no vapor por 5 minutos"}, {"step": 6, "description": "Sirva tudo junto"}]'::jsonb,
ARRAY['proteína', 'ganho de massa', 'completo']),

('Bowl de Quinoa e Grão-de-Bico', 'Opção vegetariana rica em proteínas', 'Pratos Principais', 'medium', 10, 20, 2, 380, 16, 52, 12,
'[{"item": "Quinoa", "quantity": "100g"}, {"item": "Grão-de-bico cozido", "quantity": "150g"}, {"item": "Abacate", "quantity": "1/2 unidade"}, {"item": "Tomate", "quantity": "100g"}, {"item": "Pepino", "quantity": "50g"}, {"item": "Limão", "quantity": "1 unidade"}, {"item": "Azeite", "quantity": "1 colher de sopa"}]'::jsonb,
'[{"step": 1, "description": "Cozinhe a quinoa em água fervente por 15 minutos"}, {"step": 2, "description": "Escorra e deixe esfriar"}, {"step": 3, "description": "Corte o abacate, tomate e pepino em cubos"}, {"step": 4, "description": "Em uma tigela, misture a quinoa e o grão-de-bico"}, {"step": 5, "description": "Adicione os vegetais cortados"}, {"step": 6, "description": "Tempere com suco de limão, azeite, sal e pimenta"}]'::jsonb,
ARRAY['vegetariano', 'proteína vegetal', 'saudável']);