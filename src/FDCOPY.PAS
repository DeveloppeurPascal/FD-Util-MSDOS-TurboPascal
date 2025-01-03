program file_and_directory_copy;
{
Auteur: Premartin Patrick
Date: 01/09/1991.
      09/09/1991.
Langage: Turbo Pascal 6.0
But: Copie de r‚pertoires et de fichiers.
}
uses
    crt,
    dos,
    olf_software,
    u_code_clavier,
    u_fdtree,
    u_file,
    u_m_util,
    u_parametre;

const
     num_vers : string [3] = '1.0';
     dat_vers : string [10] = '01/09/1991';

type
    o_prg = object (o_fdtree)
                   dest_dir,
                   dest : string;
                   function treat_file (f : searchrec) : boolean; virtual;
                   function treat_directory (d : searchrec) : boolean; virtual;
                   function stop_run : boolean; virtual;
    end;

function o_prg.treat_file (f : searchrec) : boolean;
var
   fich : file;
   path : string;
begin
     getdir (0, path);
     delete (path, 1, length (get_start_directory));
     dest_dir := dest + path;
     write (f.name : 16);
     treat_file := copy_file (f.name, dest_dir+'\'+f.name);
end; { O_Prg.Treat_File }

function o_prg.treat_directory (d : searchrec) : boolean;
var
   path : string;
begin
     getdir (0, path);
     delete (path, 1, length (get_start_directory));
     dest_dir := dest + path;
     if ((d.name = '.') or (d.name = '..'))
     then
         treat_directory := true
     else
         begin
              writeln;
              getdir (0, path);
              writeln ('Copy ', path, ' to ', dest_dir);
              if (path <> get_start_directory)
              then
                  begin
                       {$i-}
                       mkdir (dest_dir);
                       {$i+}
                       treat_directory := (ioresult = 0);
                  end
              else
                  treat_directory := true;
              {endif}
         end;
     {endif}
end; { O_Prg.Treat_Directory }

function o_prg.stop_run : boolean;
begin
     stop_run := (readkey in [' ', touche_escape]);
end; { O_Prg.Stop_Run }

var
   dir,
   dir_2 : dirstr;
   name : namestr;
   ext : extstr;
   prog : o_prg;

begin
     init_olf_message (mess_careware);
     init_licence ('fdutil');
     init_ligne_olf_software ('File and Directory Copy '+num_vers, #155' PREPAT '+dat_vers);
     if (param_del ('H'))
     then
         begin
              writeln ('Syntax:');
              writeln ('        fdcopy directory_1 directory_2 [/h]');
              writeln;
              writeln ('This program copy all files and directories from Directory_1');
              writeln ('to Directory_2.');
              writeln;
              writeln ('For example: FDCOPY c:\dos\*.exe a:\');
              writeln ('This sentence wille copy all EXE files in DOS directory to drive A:');
              writeln ('If DOS contains a directory, it will be copied to drive A:');
         end
     else
         if (paramcount >=2)
         then
             begin
                  prog.init;
                  fsplit (fexpand (paramstr (2)), dir_2, name, ext);
                  if (name <> '')
                  then
                      dir_2 := dir_2+name+ext+'\';
                  {endif}
                  fsplit (fexpand (paramstr (1)), dir, name, ext);
                  if (name = '')
                  then
                      name := '*';
                  {endif}
                  if ((ext = '') or (ext = '.'))
                  then
                      ext := '.*';
                  {endif}
                  if (confirm ('Copy '+dir+name+ext+' to '+dir_2+' ?'))
                  then
                      begin
                           prog.set_start_directory (dir);
                           prog.set_file_mask (name+ext);
                           prog.set_fdtree_sens (postfixe);
                           prog.dest := dir_2;
                           delete (prog.dest, length (prog.dest), 1);
                           prog.run;
                      end;
                  {endif}
                  prog.done;
                  writeln;
                  writeln ('End of program...');
             end
         else
             writeln ('Invalid parameters...');
         {endif}
     {endif}
end.
