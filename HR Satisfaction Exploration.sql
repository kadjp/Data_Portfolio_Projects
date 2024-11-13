-- Finding the average satisfaction scores by department


SELECT dept, ROUND(AVG(satisfaction_level),3) AS average_satisfaction
FROM emp_attrition
GROUP BY dept
ORDER BY 2 DESC;

-- Looking for any relationship between salary and satisfaction score


SELECT salary,ROUND(AVG(satisfaction_level),3) AS average_satisfaction
FROM emp_attrition
GROUP BY salary
ORDER BY 2 DESC;

-- Comparing the top two and bottom two departments with the highest and lowest satisfaction scores

CREATE TEMPORARY TABLE High_Low
SELECT *
FROM emp_attrition
WHERE dept = 'management'  
OR dept = 'product_mng'
OR dept = 'hr' 
OR dept = 'accounting';


SELECT *
FROM High_Low;


SELECT dept, ROUND(AVG(last_evaluation), 3) AS avg_last_eval, ROUND(AVG(satisfaction_level),3) AS avg_dept_sat
FROM High_Low
GROUP BY dept
ORDER BY avg_dept_sat DESC; -- Comparing latest evaluation scores


SELECT dept, ROUND(AVG(number_project),1) AS avg_projects, ROUND(AVG(average_montly_hours),0) AS avg_hours, ROUND(AVG(satisfaction_level),3) AS avg_dept_sat
FROM High_Low
GROUP BY dept
ORDER BY avg_dept_sat DESC; -- Comparing number of projects and number of hours for each department


SELECT dept, ROUND(AVG(time_spend_company),2) AS avg_emp_hired, ROUND(AVG(promotion_last_5years),3) AS avg_promo, ROUND(AVG(satisfaction_level),3) AS avg_dept_sat
FROM High_Low
GROUP BY dept
ORDER BY avg_dept_sat DESC; -- Comparing an employee's time with the company and rate of promotion per department


SELECT dept, AVG(Work_accident) AS avg_accident, ROUND(AVG(satisfaction_level),3) AS avg_dept_sat
FROM High_Low
GROUP BY dept
ORDER BY avg_dept_sat DESC; -- Comparing work_accidents with satisfaction scores
