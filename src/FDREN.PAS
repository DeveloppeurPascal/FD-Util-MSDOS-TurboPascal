program file_and_directory_rename;
{
Auteur: Pr‚martin Patrick.
Date: 01/09/1991.
Langage: Turbo Pascal 6.0
But: Renommer des fichiers et des r‚pertoires.
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

function test (nom_fich : string) : boolean;
var
   i : integer;
   erreur : boolean;
begin
     for i := 1 to length (nom_fich) do
         erreur := (erreur or (nom_fich [i] in ['*', '?']));
     {endfor}
     test := not erreur;
end; { Test }

var
   old_name,
   new_name : string;
   old_dir,
   dir : dirstr;
   name : namestr;
   ext : extstr;
   err,
   a,
   b,
   c,
   d : word;

begin
     init_olf_message (mess_careware);
     init_licence ('fdutil');
     init_ligne_olf_software ('File and Directory Rename '+num_vers, #155' PrePat '+dat_vers);
     if (param_del ('/H') or param_del ('/?'))
     then
         begin
              writeln ('Syntax:');
              writeln ('       fdren old_name new_name [/h]');
              writeln;
              writeln ('* and ? are not vailable in file names !');
              writeln ('This program can rename a file or a directory.');
              writeln ('/h displays this short help.');
         end
     else
         if (paramcount = 2)
         then
             begin
                  getdir (0, old_dir);
                  fsplit (fexpand (paramstr (2)), dir, name, ext);
                  new_name := name+ ext+ chr (0);
                  fsplit (fexpand (paramstr (1)), dir, name, ext);
                  if (dir [pred (length (dir))] = ':')
                  then
                      chdir (dir)
                  else
                      chdir (copy (dir, 1, pred (length (dir))));
                  {endif}
                  old_name := name+ ext+ chr (0);
                  if (test (old_name) and test (new_name))
                  then
                      begin
                           a := seg (old_name [1]);
                           b := ofs (old_name [1]);
                           c := seg (new_name [1]);
                           d := ofs (new_name [1]);
                           asm
                              push ax
                              push ds
                              push dx
                              push es
                              push di
                              mov ah, $56
                              mov ds, a
                              mov dx, b
                              mov es, c
                              mov di, d
                              int $21
                              jc @erreur
                              mov err, 0
                              jmp @fin
                           @erreur:
                                   mov err, ax
                           @fin:
                              pop di
                              pop es
                              pop dx
                              pop ds
                              pop ax
                           end;
                           case err of
                                $0 : writeln ('No error appears...');
                                $2 : writeln ('Error: ', paramstr (1), ' does not exist !');
                                $3 : writeln ('Error: ', dir, ' does not exist !');
                                $5 : writeln ('Error: Access denied...');
                                $11 : writeln ('Error: Source and destination drive may be the same...');
                           else
                               writeln ('Undefined error appears...');
                           end;
                      end
                  else
                      writeln ('File name error...');
                  {endif}
                  chdir (old_dir);
             end
         else
             writeln ('Invalid parameters...');
         {endif}
     {endif}
end.
