CREATE OR REPLACE FUNCTION GET_NB_WORKERS(factory_id NUMBER) 
RETURN NUMBER IS
    num_workers NUMBER;
BEGIN
    SELECT COUNT(*) INTO num_workers
    FROM ALL_WORKERS aw
    JOIN workers_factory_1 w1 ON aw.first_name = w1.first_name AND aw.last_name = w1.last_name
    JOIN factories f ON w1.factory_id = f.id
    WHERE f.id = factory_id;

    RETURN num_workers;
END;

CREATE OR REPLACE FUNCTION GET_NB_BIG_ROBOTS RETURN NUMBER IS
    nb_big_robots NUMBER;
BEGIN
    SELECT COUNT(DISTINCT rf.robot_id)
    INTO nb_big_robots
    FROM robots_has_spare_parts rf
    JOIN robots r ON rf.robot_id = r.id
    GROUP BY rf.robot_id
    HAVING COUNT(rf.spare_part_id) > 3;

    RETURN nb_big_robots;
END GET_NB_BIG_ROBOTS;

CREATE OR REPLACE FUNCTION GET_BEST_SUPPLIER
RETURN VARCHAR2
IS
    best_supplier_name VARCHAR2(100);
BEGIN
    SELECT supplier_name
    INTO best_supplier_name
    FROM BEST_SUPPLIERS
    ORDER BY total_quantity_delivered DESC
    FETCH FIRST 1 ROW ONLY;

    RETURN best_supplier_name;
END GET_BEST_SUPPLIER;

CREATE OR REPLACE FUNCTION GET_OLDEST_WORKER RETURN NUMBER IS
    oldest_worker_id NUMBER;
BEGIN
    SELECT worker_id
    INTO oldest_worker_id
    FROM ALL_WORKERS_ELAPSED
    ORDER BY days_elapsed DESC
    FETCH FIRST 1 ROWS ONLY;

    RETURN oldest_worker_id;
END;

CREATE OR REPLACE PROCEDURE SEED_DATA_WORKERS(
    NB_WORKERS NUMBER, 
    FACTORY_ID NUMBER
) IS
BEGIN
    FOR i IN 1..NB_WORKERS LOOP
        DECLARE
            worker_id NUMBER;
            start_date DATE;
        BEGIN
            start_date := DATE '2065-01-01' + DBMS_RANDOM.VALUE(0, 1826);

            INSERT INTO workers_factory_1 (first_name, last_name, age, first_day, last_day, factory_id)
            VALUES ('worker_f_' || workers_factory_1_seq.NEXTVAL, 'worker_l_' || workers_factory_1_seq.NEXTVAL, TRUNC(DBMS_RANDOM.VALUE(18, 65)), start_date, NULL, FACTORY_ID)
            RETURNING id INTO worker_id;
            
            INSERT INTO workers_factory_2 (worker_id, first_name, last_name, start_date, end_date)
            VALUES (worker_id, 'worker_f_' || worker_id, 'worker_l_' || worker_id, start_date, NULL);
        END;
    END LOOP;
END;

CREATE OR REPLACE PROCEDURE ADD_NEW_ROBOT(MODEL_NAME VARCHAR2) IS
BEGIN
    INSERT INTO robots (model)
    VALUES (MODEL_NAME);
    
    COMMIT;
END ADD_NEW_ROBOT;

CREATE OR REPLACE PROCEDURE SEED_DATA_SPARE_PARTS(NB_SPARE_PARTS NUMBER) IS
BEGIN
    FOR i IN 1..NB_SPARE_PARTS LOOP
        INSERT INTO spare_parts (name)
        VALUES ('Spare Part ' || TO_CHAR(i));
    END LOOP;

    COMMIT;
END SEED_DATA_SPARE_PARTS;