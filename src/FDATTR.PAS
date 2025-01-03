program File_and_directory_attribut;
{
Auteur: Premartin Patrick
Date: 01/09/1991.
Langage: Turbo Pascal 6.0
But: Mofifier l'attribut d'un r‚pertoire ou d'un fichier.
}
uses
    crt,
    dos,
    olf_software,
    u_code_clavier,
    u_m_util,
    u_parametre;

const
     num_vers : string [3] = '1.0';
     dat_vers : string [10] = '01/09/1991';

var
   modif_dir : boolean;

function set_file_attr (nom_fich : string; attr : word) : word;
var
   ch : string;
   err,
   sg,
   fs : word;
begin
     ch := fexpand (nom_fich) + chr (0);
     sg := seg (ch);
     fs := succ (ofs (ch));
     asm
        push ax
        push ds
        push cx
        push dx
        mov ah, $43
        mov al, 1
        mov cx, attr
        mov ds, sg
        mov dx, fs
        int $21
        jc @erreur
        mov err,0
        jmp @fin
     @erreur:
             mov err, ax
     @fin:
          pop dx
          pop cx
          pop ds
          pop ax
     end;
     set_file_attr := err;
end; { Set_File_Attr }

function new_attr (old_attr : word) : word;
var
   i : integer;
   j,
   k : word;
   ch : string;
begin
     j := old_attr;
     for i := 1 to paramcount do
         begin
              ch := paramstr (i);
              if (length (ch) = 2)
              then
                  begin
                       case upcase (ch [2]) of
                            'R' : k := readonly;
                            'H' : k := hidden;
                            'S' : k := sysfile;
                            'A' : k := archive;
                       else
                           k := 0;
                       end;
                       if (k > 0)
                       then
                           case (ch [1]) of
                                '+' : if (j and k = 0)
                                      then
                                          j := j + k;
                                      {endif}
                                '-' : if (j and k <> 0)
                                      then
                                          j := j - k;
                                      {endif}
                           end;
                       {endif}
                  end;
              {endif}
         end;
     {endfor}
     new_attr := j;
end; { New_Attr }

function traite (mask : string) : boolean;
var
   nom_fich : searchrec;
   fin : boolean;
begin
     fin := false;
     findfirst (mask, $ffff, nom_fich);
     while ((doserror = 0) and not fin) do
           begin
                if ((nom_fich.name <> '.') and (nom_fich.name <> '..'))
                then
                    if (nom_fich.attr and directory <> 0)
                    then
                        begin
                             if (modif_dir and confirm ('Modify directory '+nom_fich.name+' ?'))
                             then
                                 begin
                                      writeln;
                                      writeln ('Directory: ', nom_fich.name);
                                      fin := fin or (set_file_attr (nom_fich.name, new_attr (nom_fich.attr)) <> 0);
                                 end;
                             {endif}
                        end
                    else
                        if (nom_fich.attr and volumeid = 0)
                        then
                            begin
                                 write (nom_fich.name : 16);
                                 fin := fin or (set_file_attr (nom_fich.name, new_attr (nom_fich.attr)) <> 0);
                            end;
                        {endif}
                    {endif}
                {endif}
                if keypressed
                then
                    fin := fin or (readkey in [' ', touche_escape]);
                {endif}
                findnext (nom_fich);
           end;
     {endwhile}
     traite := not fin;
end; { Traite }

var
   i : integer;
   ch : string;
   fin : boolean;
   old_dir,
   dir : dirstr;
   name : namestr;
   ext : extstr;

begin
     init_licence ('fdutil');
     init_olf_message (mess_careware);
     init_ligne_olf_software ('File and Directory Attribut '+num_vers, #155' Pr‚martin Patrick '+dat_vers);
     modif_dir := param_del ('D');
     if (param_del ('/H') or (param_del ('/?')))
     then
         begin
              writeln ('Syntax:');
              writeln ('        fdattr ['#241'a] ['#241'h] ['#241'r] ['#241's] [/h] [/d] [[file_name]...]');
              writeln;
              writeln ('Modify the attribut of File_Name (it can be a file or a directory).');
              writeln (' + activ an option, - desactiv it.');
              writeln ('A is for an archive file or directory.');
              writeln ('H is for a hidden file or directory.');
              writeln ('R is for a read only file or directory.');
              writeln ('S is for a system file or directory.');
              writeln;
              writeln ('You can not use all options for a directory with some DOS version.');
              writeln;
              writeln ('/h for this short help.');
              writeln ('/d to autorize directories modifications. Be very cautious: modifications');
              writeln ('are irreparable !!!!!!!!!!!!!!!!!');
         end
     else
         begin
              getdir (0, old_dir);
              i := 1;
              fin := false;
              while ((i <= paramcount) and not fin) do
                    begin
                         ch := paramstr (i);
                         if not (ch [1] in ['-', '+', '/'])
                         then
                             begin
                                  fsplit (fexpand (ch), dir, name, ext);
                                  if (dir [pred (length (dir))] = ':')
                                  then
                                      chdir (dir)
                                  else
                                      chdir (copy (dir, 1, pred (length (dir))));
                                  {endif}
                                  fin := not traite (name+ext);
                             end;
                         {endif}
                         inc (i);
                    end;
              {endwhile}
              writeln;
              if (fin)
              then
                  writeln ('Operation abort...');
              {endif}
              chdir (old_dir);
         end
     {endif}
end.
