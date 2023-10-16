# Dominoes

    Code
      cat_piece(df)
    Output
          ┌─┬───┬─┐      
          │󼨁│󼨔┃󼨕│󼨂│      
      ┌─┐ │━├───┤━│      
      │󼨄│ │󼨁│   │󼨆│      
      │━├─┴─┤ ┌─┼─┴─┬─┐  
      │󼨄│󼨗┃󼨔│ │󼨆│󼨙┃󼨙│󼨆│  
      └─┴─┬─┤ │━├───┤━│  
          │󼨁│ │󼨅│   │󼨄│  
      ┌───┤━├─┴─┤   ├─┴─┐
      │󼨕┃󼨘│󼨅│󼨘┃󼨘│   │󼨗┃󼨓│
      └─┬─┼─┼─┬─┘   └───┘
        │󼨅│ │󼨅│          
        │━│ │━│          
        │󼨀│ │󼨄│          
        └─┘ └─┘          

# Can't rotate boards

    Code
      cat_piece(ppdf::checkers_italian_checkers(), annotate = "cartesian")
    Output
       ┌─┰─┰─┰─┰─┰─┰─┰─┐
      8│⛂┃ ┃⛂┃ ┃⛂┃ ┃⛂┃ │
       ┝━╋━╋━╋━╋━╋━╋━╋━┥
      7│ ┃⛂┃ ┃⛂┃ ┃⛂┃ ┃⛂│
       ┝━╋━╋━╋━╋━╋━╋━╋━┥
      6│⛂┃ ┃⛂┃ ┃⛂┃ ┃⛂┃ │
       ┝━╋━╋━╋━╋━╋━╋━╋━┥
      5│ ┃ ┃ ┃ ┃ ┃ ┃ ┃ │
       ┝━╋━╋━╋━╋━╋━╋━╋━┥
      4│ ┃ ┃ ┃ ┃ ┃ ┃ ┃ │
       ┝━╋━╋━╋━╋━╋━╋━╋━┥
      3│ ┃⛀┃ ┃⛀┃ ┃⛀┃ ┃⛀│
       ┝━╋━╋━╋━╋━╋━╋━╋━┥
      2│⛀┃ ┃⛀┃ ┃⛀┃ ┃⛀┃ │
       ┝━╋━╋━╋━╋━╋━╋━╋━┥
      1│ ┃⛀┃ ┃⛀┃ ┃⛀┃ ┃⛀│
       └─┸─┸─┸─┸─┸─┸─┸─┘
        1 2 3 4 5 6 7 8 
