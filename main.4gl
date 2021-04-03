SCHEMA custdemo

MAIN
DEFINE id LIKE Orgnchart.Id,
des LIKE  Orgnchart.Hierachdesc,
val LIKE  Orgnchart.Hierachvalue,
pid LIKE  Orgnchart.Parent_Id

DEFINE rep REPORT
id LIKE Orgnchart.Id,
des LIKE  Orgnchart.Hierachdesc,
val LIKE  Orgnchart.Hierachvalue,
pid LIKE  Orgnchart.Parent_Id
END REPORT 

select A.HierachDesc ,A.Id, B.HierachDesc,B.Id,c.HierachDesc,c.Id,d.HierachDesc,d.Id
from Orgnchart A, Orgnchart B, Orgnchart c, Orgnchart d
where A.Id = B.Parent_Id And B.Id = c.Parent_Id AND c.Id = d.Parent_Id

    

END MAIN
