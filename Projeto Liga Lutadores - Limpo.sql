CREATE DATABASE projeto_final_l;

USE projeto_final_l;

CREATE TABLE liga_lutadores (
    id_lutador INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    pontos INT DEFAULT 0,
    partidas INT NOT NULL DEFAULT 0,
    vitorias INT NOT NULL DEFAULT 0,
    empates INT NOT NULL DEFAULT 0,
    derrotas INT NOT NULL DEFAULT 0,
    saldo_p INT DEFAULT 0
);

CREATE TABLE dados_lutador (
    id_lutador INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    idade INT NOT NULL,
    genero ENUM('M','F'),
    dt_nascimento DATE NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    signo VARCHAR(20),
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(20)
);

CREATE TABLE dados_treinador (
    id_treinador INT PRIMARY KEY AUTO_INCREMENT,
    nome_treinador VARCHAR(100) NOT NULL,
    idade INT NOT NULL,
    genero ENUM('M','F'),
    dt_nascimento DATE NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(20)
);

CREATE TABLE treinador_lutador (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_lutador INT NOT NULL,
    id_treinador INT NOT NULL,
    FOREIGN KEY (id_lutador) REFERENCES dados_lutador(id_lutador),
    FOREIGN KEY (id_treinador) REFERENCES dados_treinador(id_treinador)
);

CREATE TABLE confrontos (
   id_confronto INT PRIMARY KEY AUTO_INCREMENT,
   lutador1 VARCHAR(100) NOT NULL,
   placar1 INT NOT NULL,
   vs ENUM('x'),
   placar2 INT NOT NULL,
   lutador2 VARCHAR(100) NOT NULL
);

CREATE TABLE melhores_l (
    id_lutador INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    pontos INT
);

CREATE TABLE rivalidade (
    id_rivalidade INT AUTO_INCREMENT PRIMARY KEY,
    lutador_a VARCHAR(100),
    lutador_b VARCHAR(100),
    qtd_confrontos INT
);

SELECT * FROM dados_lutador;

######################
# 1° GATILHO PARA ATUALIZAR VITORIAS,DERROTAS OU EMPATES DA LIGA DOS LUTADORES DE ACORDO COM O RESULTADO DOS CONFRONTOS
DELIMITER $$

CREATE TRIGGER atualizar_vitorias
AFTER INSERT ON confrontos
FOR EACH ROW
BEGIN
    IF NEW.placar1 > NEW.placar2 THEN
        -- Lutador 1 venceu
        UPDATE liga_lutadores
        SET vitorias = vitorias + 1
        WHERE nome = NEW.lutador1;

        -- Lutador 2 perdeu
        UPDATE liga_lutadores
        SET derrotas = derrotas + 1
        WHERE nome = NEW.lutador2;

    ELSEIF NEW.placar2 > NEW.placar1 THEN
        -- Lutador 2 venceu
        UPDATE liga_lutadores
        SET vitorias = vitorias + 1
        WHERE nome = NEW.lutador2;

        -- Lutador 1 perdeu
        UPDATE liga_lutadores
        SET derrotas = derrotas + 1
        WHERE nome = NEW.lutador1;

    ELSE
        -- Empate (ambos recebem um empate)
        UPDATE liga_lutadores
        SET empates = empates + 1
        WHERE nome = NEW.lutador1;

        UPDATE liga_lutadores
        SET empates = empates + 1
        WHERE nome = NEW.lutador2;
    END IF;
END $$

DELIMITER ;
############

# 2° GATILHO PARA Atualizar a quantidade de partidas dos lutadores dps de um confronto novo ser inserido
DELIMITER $$

CREATE TRIGGER atualizar_partidas
AFTER INSERT ON confrontos
FOR EACH ROW
BEGIN
    UPDATE liga_lutadores
    SET partidas = partidas + 1
    WHERE nome = NEW.lutador1;

    UPDATE liga_lutadores
    SET partidas = partidas + 1
    WHERE nome = NEW.lutador2;
END $$

DELIMITER ;

############

SELECT * FROM dados_lutador;

# 3° GATILHO PARA inserir automaticamente o lutador na liga apos criar o lutador
DELIMITER $$

CREATE TRIGGER inserir_lutador_liga
AFTER INSERT ON dados_lutador
FOR EACH ROW
BEGIN
    INSERT INTO liga_lutadores (id_lutador, nome)
    VALUES (NEW.id_lutador, NEW.nome);
END $$
DELIMITER ;

############

SELECT * FROM dados_lutador;

# GATILHO 4 , calcular pontos dos lutadores
DELIMITER $$

CREATE TRIGGER pontos_update
BEFORE UPDATE ON liga_lutadores
FOR EACH ROW
BEGIN
    SET NEW.pontos = (NEW.vitorias * 2) - NEW.derrotas + NEW.empates;
END $$
DELIMITER ;

####

SELECT * FROM dados_lutador;

# GATILHO 5 , saldo de partidas
DELIMITER $$

CREATE TRIGGER saldo_partidas_update
BEFORE UPDATE ON liga_lutadores
FOR EACH ROW
BEGIN
    SET NEW.saldo_p = NEW.vitorias - NEW.derrotas;
END $$

DELIMITER ;
#########

SELECT * FROM dados_lutador;

# GATILHO 6 , VARIAÇÃO DO 3 SOQUE COM UPDATE
DELIMITER $$

CREATE TRIGGER atualizar_vitorias_update
BEFORE UPDATE ON confrontos
FOR EACH ROW
BEGIN
    # removendo o resultado anterior
    IF OLD.placar1 > OLD.placar2 THEN
        UPDATE liga_lutadores SET vitorias = vitorias - 1 WHERE nome = OLD.lutador1;
        UPDATE liga_lutadores SET derrotas = derrotas - 1 WHERE nome = OLD.lutador2;
    ELSEIF OLD.placar2 > OLD.placar1 THEN
        UPDATE liga_lutadores SET vitorias = vitorias - 1 WHERE nome = OLD.lutador2;
        UPDATE liga_lutadores SET derrotas = derrotas - 1 WHERE nome = OLD.lutador1;
    ELSE
        UPDATE liga_lutadores SET empates = empates - 1 WHERE nome = OLD.lutador1;
        UPDATE liga_lutadores SET empates = empates - 1 WHERE nome = OLD.lutador2;
    END IF;

    # adicionando o novo
    IF NEW.placar1 > NEW.placar2 THEN
        UPDATE liga_lutadores SET vitorias = vitorias + 1 WHERE nome = NEW.lutador1;
        UPDATE liga_lutadores SET derrotas = derrotas + 1 WHERE nome = NEW.lutador2;
    ELSEIF NEW.placar2 > NEW.placar1 THEN
        UPDATE liga_lutadores SET vitorias = vitorias + 1 WHERE nome = NEW.lutador2;
        UPDATE liga_lutadores SET derrotas = derrotas + 1 WHERE nome = NEW.lutador1;
    ELSE
        UPDATE liga_lutadores SET empates = empates + 1 WHERE nome = NEW.lutador1;
        UPDATE liga_lutadores SET empates = empates + 1 WHERE nome = NEW.lutador2;
    END IF;
END $$

DELIMITER ;

######

SELECT * FROM dados_lutador;

# GATILHO 7 , VARIAÇÃO DO 2 SOQUE COM UPDATE
DELIMITER $$

CREATE TRIGGER atualizar_partidas_update
BEFORE UPDATE ON confrontos
FOR EACH ROW
BEGIN
    # removendo qtd de partidas anterior
    UPDATE liga_lutadores SET partidas = partidas - 1 WHERE nome = OLD.lutador1;
    UPDATE liga_lutadores SET partidas = partidas - 1 WHERE nome = OLD.lutador2;

    #adicionando novas
    UPDATE liga_lutadores SET partidas = partidas + 1 WHERE nome = NEW.lutador1;
    UPDATE liga_lutadores SET partidas = partidas + 1 WHERE nome = NEW.lutador2;
END $$

DELIMITER ;

#######

SELECT * FROM dados_lutador;

# GATILHO 8 DELETAR OS PONTOS,VITORIAS,DERROTAS,EMPATES E PARTIDAS DO CONFRONTO APO DELETAR O CONFRONTO
DELIMITER $$
CREATE TRIGGER Delete_Confrontos
AFTER DELETE ON confrontos
FOR EACH ROW
BEGIN
    IF OLD.placar1 > OLD.placar2 THEN
        UPDATE liga_lutadores SET vitorias = vitorias - 1 WHERE nome = OLD.lutador1;
	UPDATE liga_lutadores SET derrotas = derrotas - 1 WHERE nome = OLD.lutador2;

	UPDATE liga_lutadores SET partidas = partidas - 1 WHERE nome = OLD.lutador1;
	UPDATE liga_lutadores SET partidas = partidas - 1 WHERE nome = OLD.lutador2;

    ELSEIF OLD.placar2 > OLD.placar1 THEN
        UPDATE liga_lutadores SET vitorias = vitorias - 1 WHERE nome = OLD.lutador2;
	UPDATE liga_lutadores SET derrotas = derrotas - 1 WHERE nome = OLD.lutador1;

	UPDATE liga_lutadores SET partidas = partidas - 1 WHERE nome = OLD.lutador2;
	UPDATE liga_lutadores SET partidas = partidas - 1 WHERE nome = OLD.lutador1;
    ELSE
        UPDATE liga_lutadores SET empates = empates - 1 WHERE nome = OLD.lutador1;
	UPDATE liga_lutadores SET empates = empates - 1 WHERE nome = OLD.lutador2;
        
	UPDATE liga_lutadores SET partidas = partidas - 1 WHERE nome = OLD.lutador1;
	UPDATE liga_lutadores SET partidas = partidas - 1 WHERE nome = OLD.lutador2;
    END IF;
END$$
DELIMITER ;

####

#  1° VIEW NÚMERO UM, A MAIS IMPORTANTE, QUE VÊ A tabela liga_lutadores em ordem certa
CREATE VIEW ranking_liga AS 
SELECT 
    nome,
    pontos,
    vitorias,
    empates,
    derrotas,
    partidas,
    saldo_p
FROM liga_lutadores
ORDER BY pontos DESC;
#####

SELECT * FROM liga_lutadores;

# 2° View,para ver o nome dos lutadores e dos teinadores em vez do ID
CREATE VIEW visu_tl AS
SELECT
    dt.nome_treinador AS Treinador,
    dl.nome AS Lutador
FROM
    treinador_lutador tl
JOIN
    dados_treinador dt ON tl.id_treinador = dt.id_treinador
JOIN
    dados_lutador dl ON tl.id_lutador = dl.id_lutador;

# testando a 2° view
SELECT * FROM visu_tl;

# 3° View mostrando lutadores que tem mais vitoria que derrota
CREATE VIEW MV AS
SELECT * FROM liga_lutadores
WHERE vitorias > derrotas
ORDER BY pontos DESC;

# testando a 3° view
SELECT * FROM MV;

# 4° View mostrando lutadores que tem mais derrota que vitoria 
CREATE VIEW MP AS
SELECT * FROM liga_lutadores
WHERE derrotas > vitorias
ORDER BY pontos DESC;

# testando a 4° view
SELECT * FROM MP;

# 5° view mostra lutadores com a mesma quantidade de vitorias e derrotas
CREATE VIEW LE AS
SELECT * FROM liga_lutadores
WHERE derrotas = vitorias
ORDER BY pontos DESC;

# testando a 5° view 
SELECT * FROM LE;

# 6° View lutadores apenas do genênero feminino(F)
CREATE VIEW l_femininos AS
SELECT * FROM dados_lutador
WHERE genero = "F";

# testando a 6° view
SELECT * FROM l_femininos;

# 7° View lutadores apenas do genênero masculinos(M)
CREATE VIEW l_masculinos AS
SELECT * FROM dados_lutador
WHERE genero = "M";

# testando a 7° view
SELECT * FROM l_masculinos;

# 8° view mostra os lutadores(as) do mais velho para o novo 
CREATE VIEW order_idade AS
SELECT nome, idade
FROM dados_lutador
ORDER BY idade DESC;

# testando a 8° view
SELECT * FROM order_idade;

# 9° view mostra estatísticas das lutadores femininas
CREATE VIEW EF AS
SELECT
  genero,
  SUM(pontos) AS total_pontos
FROM liga_lutadores l
JOIN dados_lutador d ON l.id_lutador = d.id_lutador
GROUP BY genero
HAVING genero = 'F';

# testando a 9° view 
SELECT * FROM EF;

# 10° view mostra estatísticas das lutadores masculinos
CREATE VIEW EM AS
SELECT
  genero,
  SUM(pontos) AS total_pontos
FROM liga_lutadores l
JOIN dados_lutador d ON l.id_lutador = d.id_lutador
GROUP BY genero
HAVING genero = 'M';
# testando a 10° view
SELECT * FROM EM;

# 11° view mostra a comparação dos dois juntos
CREATE VIEW EG AS
SELECT
  genero,
  SUM(pontos) AS total_pontos
FROM liga_lutadores l
JOIN dados_lutador d ON l.id_lutador = d.id_lutador
GROUP BY genero;
# testando a 11° view
SELECT * FROM EG;

# adicionando os lutadores e testando gatilho 3
INSERT INTO dados_lutador (nome, idade, genero, dt_nascimento, cpf, signo, email, telefone)
VALUES
('Shermie', 30, 'F', '1994-03-30', '528.921.748-58', 'Áries', 'shermie@gmail.com', '(83) 95161-0529'),
('Mai Shiranui', 39, 'F', '1985-03-24', '283.709.190-60', 'Áries', 'mai.shiranui@gmail.com', '(65) 96073-3763'),
('Rainbow Ibuki', 34, 'F', '1990-04-03', '983.027.143-02', 'Áries', 'rainbow.ibuki@gmail.com', '(27) 98802-3419'),
('Cocó', 36, 'M', '1987-12-30', '870.345.290-77', 'Capricórnio', 'coco@gmail.com', '(98) 97145-1097'),
('Edu Bronqs', 35, 'M', '1990-07-01', '345.769.98-58', 'Capricórnio', 'charlinho@gmail.com', '(11) 97754-6546'),
('Lea', 31, 'F', '1994-09-12', '643.123.98-65', 'Peixes', 'calabrations@gmail.com', '(95) 98673-5474');

# adicionando os treinadores
INSERT INTO dados_treinador (nome_treinador, idade, genero, dt_nascimento, cpf, email, telefone)
VALUES
('Mr Bison', 30, 'M', '1994-03-30', '528.921.748-58', 'mr.bison@gmail.com', '(83) 95161-0529'),
('Khabibi Macaxheve', 21, 'M', '2003-03-04', '491.027.385-40', 'khabibi.macaxheve@gmail.com', '(91) 93201-6322'),
('Chun-li', 28, 'F', '1995-06-26', '471.981.634-29', 'chun.li@gmail.com', '(84) 95083-7092'),
('Li Bagacier', 32, 'F', '1992-08-01', '690.728.403-85', 'li.bagacier@gmail.com', '(35) 98094-3789'),
('Brunega Sirenni', 19, 'M', '2006-03-21', '643.546.865-51', 'ncurtoxere@gmail.com', '(45) 99542-5335');

DELETE FROM dados_treinador WHERE nome_treinador = "Brunega Sirenni";
DELETE FROM dados_lutador WHERE nome = "Edu Bronqs";
DELETE FROM dados_lutador WHERE nome = "Lea";

DELETE FROM liga_lutadores WHERE id_lutador = 5;
DELETE FROM liga_lutadores WHERE id_lutador = 6;

# criando a relação entre treinadores e lutadores
INSERT INTO treinador_lutador (id_lutador, id_treinador)
VALUES
(4, 1),  # Mr Bison treina Cocó
(2, 2),  # Khabibi Macaxheve treina Mai Shiranui
(3, 3), # Chun-li treina Rainbow Ibuki
(1, 4); # Li Bagacier treina Shermie

SET SQL_SAFE_UPDATES = 0;

# testando gatilho 1,2 e 4, 40 confrontos, cada lutador lutando 4 vezes
INSERT INTO confrontos (lutador1, placar1, vs, placar2, lutador2)
VALUES 
('Shermie', 4, 'x', 3, 'Cocó'),
('Mai Shiranui', 3, 'x', 1, 'Rainbow Ibuki');

# testando gatilho 4,5, 6 7
UPDATE confrontos
SET placar1 = 3, placar2 = 3
WHERE lutador1 = 'Mai Shiranui' AND lutador2 = 'Rainbow Ibuki';

# testando a view RANKING
SELECT * FROM ranking_liga;

###

# 1° >>>>>>>>>>>>>>>>>>>>>>>>>>>> PROCEDURE  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# testando o 1° procedure
# essa procedure Promove automaticamente os 4 melhores lutadores para um torneio especial

DELIMITER $$

CREATE PROCEDURE promover_ML()
BEGIN
    # Limpa a tabela antes de inserir novos dados
    DELETE FROM melhores_l;

    # Insere os 4 lutadores com mais pontos na tabela 'melhores_l'
    INSERT INTO melhores_l (id_lutador, nome, pontos)
    SELECT id_lutador, nome, pontos
    FROM liga_lutadores
    ORDER BY pontos DESC
    LIMIT 4;
END $$

DELIMITER ;

# abaixo a gente ativa a procedure
CALL promover_ML();

#abaixo verificando se ta tudo certo
SELECT * FROM melhores_l;

# 2° >>>>>>>>>>>>>>>>>>>>>>>>>>> PROCEDURE  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# testando o 2° procedure
# essa procedure vai zerar todas as estatisticas de todos os jogadores
 
DELIMITER $$

CREATE PROCEDURE reset_liga()
BEGIN
    UPDATE liga_lutadores
    SET 
        pontos = 0,
        vitorias = 0,
        derrotas = 0,
        empates = 0,
        partidas = 0,
        saldo_p = 0;
END $$

DELIMITER ;

SELECT * FROM liga_lutadores;
# abaixo ativa a procedure
CALL reset_liga();

SELECT * FROM liga_lutadores;

# 3° >>>>>>>>>>>>>>>>>>>>>>>>>> PROCEDURE  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# testando o 3° procedure
# vai criar ter uma tabela Rivalidade e essa procedure pega os lutadores que mais se enfrentaram pra por nessa tabela

DELIMITER $$

CREATE PROCEDURE criar_rivais()
BEGIN
    # vai limpar as rivalidades anteriores
    TRUNCATE TABLE rivalidade;

    # Insere os pares ordenados e contagem de confrontos
    INSERT INTO rivalidade (lutador_a, lutador_b, qtd_confrontos)
    SELECT
        LEAST(lutador1, lutador2) AS lutador_a,
        GREATEST(lutador1, lutador2) AS lutador_b,
        COUNT(*) AS qtd_confrontos
    FROM confrontos
    GROUP BY lutador_a, lutador_b
    ORDER BY qtd_confrontos DESC;
END $$

DELIMITER ;
# decidir colocar o LEAST() e GREATEST() para evitar duplicatas do tipo “Cammy vs Mai” e “Mai vs Cammy”.

CALL criar_rivais();
# acima ativa a procedure e abaixo tem o resultado de forma ordenada descrescente
SELECT * FROM rivalidade ORDER BY qtd_confrontos DESC;

# 1° >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FUNÇAO  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# testando a 1° Função
# Essa função vai ser utilizada para atualizar ou consultar a idade em outras partes do banco.

DELIMITER $$

CREATE FUNCTION calc_idade(data_nascimento DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE idade INT;
    
    SET idade = YEAR(CURDATE()) - YEAR(data_nascimento);
    
    -- Ajusta se ainda não fez aniversário no ano corrente
    IF DATE_FORMAT(CURDATE(), '%m%d') < DATE_FORMAT(data_nascimento, '%m%d') THEN
        SET idade = idade - 1;
    END IF;
    
    RETURN idade;
END $$

DELIMITER ;
# aqui verifica a idade calculada de todos os lutadores
SELECT nome, dt_nascimento, calc_idade(dt_nascimento) AS idade_calculada
FROM dados_lutador;

# 2° >>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FUNÇÃO  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# testando a 2° Função
# essa função vai fazer um aproveitamento de um lutador com base nos seus ultimos 5 confrontos(ou seja , quantos pontos ele fez nos ultimos 5 confrontos)
DELIMITER $$

CREATE FUNCTION aproveitamento_L(nome_lutador VARCHAR(100))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE pontos INT DEFAULT 0;

    # isso vai somar os pontos dos últimos 5 confrontos em que o lutador participou
    SELECT SUM(
        CASE
            WHEN nome_lutador = lutador1 AND placar1 > placar2 THEN 2
            WHEN nome_lutador = lutador2 AND placar2 > placar1 THEN 2
            WHEN (nome_lutador = lutador1 OR nome_lutador = lutador2) AND placar1 = placar2 THEN 1
            ELSE 0
        END
    )
    INTO pontos
    FROM (
        SELECT * FROM confrontos
        WHERE lutador1 = nome_lutador OR lutador2 = nome_lutador
        ORDER BY id_confronto DESC
        LIMIT 5
    ) AS ultimos;

    RETURN IFNULL(pontos, 0);
END $$

DELIMITER ;

#aqui da pra ver de forma resumida o aproveitamento do lutador
SELECT aproveitamento_L('Shermie');
SELECT aproveitamento_L('Cocó');

# decidir criar uma view pra organizar melhor os nomes dos lutadores e seus pontos somados nos últimos 5 confrontos
CREATE OR REPLACE VIEW VerAproveitamento AS
SELECT 
    nome,
    aproveitamento_L(nome) AS VerAproveitamento
FROM liga_lutadores;

# abaixo vai verificar os aproveitamentos
SELECT * FROM VerAproveitamento;

# 3° >>>>>>>>>>>>>>>> FUNÇÃO <<<<<<<<<<<<
# testando a 3° Função
# essa função vai pegar todos os dados de um lutador especifico baseado no id dele e mostrar (nome, idade, pontos, vitorias, sado_p, cpf, telefone)
DELIMITER $$

CREATE FUNCTION perfil_L(p_id INT)
RETURNS VARCHAR(1000)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE resultado VARCHAR(1000);
    DECLARE v_nome VARCHAR(100);
    DECLARE v_idade INT;
    DECLARE v_pontos INT;
    DECLARE v_vitorias INT;
    DECLARE v_saldo_p INT;
    DECLARE v_cpf VARCHAR(14);
    DECLARE v_telefone VARCHAR(20);

    # essa parte vai coletar os dados do lutador
    SELECT 
        d.nome, d.idade, d.cpf, d.telefone,
        l.pontos, l.vitorias, l.saldo_p
    INTO 
        v_nome, v_idade, v_cpf, v_telefone,
        v_pontos, v_vitorias, v_saldo_p
    FROM dados_lutador d
    JOIN liga_lutadores l ON d.id_lutador = l.id_lutador
    WHERE d.id_lutador = p_id;

    # essa vai ser a string de retorno
    SET resultado = CONCAT(
        'Nome: ', v_nome, ', Idade: ', v_idade,
        ', Pontos: ', v_pontos, ', Vitórias: ', v_vitorias,
        ', Saldo: ', v_saldo_p, ', CPF: ', v_cpf,
        ', Telefone: ', v_telefone
    );

    RETURN resultado;
END$$

DELIMITER ;

# basta da o select ai abaixo que o senhor vai ver os resultados 
SELECT perfil_L(1);
SELECT perfil_L(3);
SELECT perfil_L(4);