;; Copyright (c) 2006-2020 Carlos Ungil

(in-package :rcl.ffi)

;; include/Embedded.h

;; extern int Rf_initEmbeddedR(int argc, char *argv[]);
;; extern void Rf_endEmbeddedR(int fatal);

(r::defcfun "Rf_initEmbeddedR" :int (argc :int) (argv :pointer))
(r::defcfun "Rf_endEmbeddedR" :void (fatal :int))

;; The functions above are implemented in src/unix/Rembedded.c (see below)

;; int Rf_initialize_R(int ac, char **av);
;; void setup_Rmainloop(void);
;; extern void R_ReplDLLinit(void);
;; extern int R_ReplDLLdo1(void);

(r::defcfun "Rf_initialize_R" :int (argc :int) (argv :pointer))
(r::defcfun "setup_Rmainloop" :void)
(r::defcfun "R_ReplDLLinit" :void)
(r::defcfun "R_ReplDLLdo1" :int)

;; void R_setStartTime(void);
;; extern void R_RunExitFinalizers(void);
;; extern void CleanEd(void);
;; extern void Rf_KillAllDevices(void);
;; LibExtern int R_DirtyImage;
;; extern void R_CleanTempDir(void);
;; LibExtern char *R_TempDir;
;; extern void R_SaveGlobalEnv(void);

(cffi:defcvar ("R_DirtyImage" :read-only t) :int)
(cffi:defcvar ("R_TempDir" :read-only t) :string)

(r::defcfun "R_setStartTime" :void)
(r::defcfun "Rf_RunExitFinalizers" :void)
(r::defcfun "CleanEd" :void)
(r::defcfun "Rf_KillAllDevices" :void)
(r::defcfun "R_CleanTempDir" :void)
(r::defcfun "R_SaveGlobalEnv" :void)

;; #ifdef _WIN32
;; extern char *getDLLVersion(void), *getRUser(void), *get_R_HOME(void);
;; extern void setup_term_ui(void);
;; LibExtern int UserBreak;
;; extern Rboolean AllDevicesKilled;
;; extern void editorcleanall(void);
;; extern int GA_initapp(int, char **);
;; extern void GA_appcleanup(void);
;; extern void readconsolecfg(void);
;; #else
;; void fpu_setup(Rboolean start);
;; #endif

#+WINDOWS (cffi:defcvar ("UserBreak" :read-only t) :int)
#+WINDOWS (cffi:defcvar ("AllDevicesKilled" :read-only t) :string)

#+WINDOWS (r::defcfun "getDLLVersion" :string)
#+WINDOWS (r::defcfun "getRUser" :string)
#+WINDOWS (r::defcfun "get_R_HOME" :string)
#+WINDOWS (r::defcfun "setup_term_ui" :void)
#+WINDOWS (r::defcfun "editorcleanall" :void)
;; #+WINDOWS (r::defcfun "GA_initapp" :void () ())
#+WINDOWS (r::defcfun "GA_appcleanup" :void)
#+WINDOWS (r::defcfun "readconsolecfg" :void)

#-WINDOWS (r::defcfun "fpu_setup" :void (start :bool))

#|
/*
 This is the routine that can be called to initialize the R environment
 when it is embedded within another application (by loading libR.so).

 The arguments are the command line arguments that would be passed to
 the regular standalone R, including the first value identifying the
 name of the `application' being run.  This can be used to indicate in
 which application R is embedded and used by R code (e.g. in the
 Rprofile) to determine how to initialize itself. These are accessible
 via the R function commandArgs().

 The return value indicates whether the initialization was successful
 (Currently there is a possibility to do a long jump within the
 initialization code so that will we never return here.)

 Example:
	 0) name of executable
	 1) don't load the X11 module
	 2) don't show the banner at startup.


    char *argv[]= {"REmbeddedPostgres", "--gui=none", "--silent"};
    Rf_initEmbeddedR(sizeof(argv)/sizeof(argv[0]), argv);
*/

int Rf_initEmbeddedR(int argc, char **argv)
{
    Rf_initialize_R(argc, argv);
    R_Interactive = TRUE;  /* Rf_initialize_R set this based on isatty */
    setup_Rmainloop();
    return(1);
}

/* use fatal !=0 for emergency bail out */
void Rf_endEmbeddedR(int fatal)
{
    R_RunExitFinalizers();
    CleanEd();
    if(!fatal) KillAllDevices();
    R_CleanTempDir();
    if(!fatal && R_CollectWarnings)
	PrintWarnings();	/* from device close and .Last */
    fpu_setup(FALSE);
}
|#
