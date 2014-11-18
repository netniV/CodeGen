<CODEGEN_FILENAME><StructureName>MaintViewModel.cs</CODEGEN_FILENAME>
<REQUIRES_USERTOKEN>MVVM_DATA_NAMESPACE</REQUIRES_USERTOKEN>
;//****************************************************************************
;//
;// Title:       cs_mvvm_maint_viewmodel.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: Template to generate a C# MVVM ViewModel class for use in a
;//              maintenance application.
;//
;// Date:        10th December 2009
;//
;// Author:      Steve Ives, Synergex Professional Services Group
;//              http://www.synergex.com
;//
;//****************************************************************************
;//
;// Copyright (c) 2012, Synergex International, Inc.
;// All rights reserved.
;//
;// Redistribution and use in source and binary forms, with or without
;// modification, are permitted provided that the following conditions are met:
;//
;// * Redistributions of source code must retain the above copyright notice,
;//   this list of conditions and the following disclaimer.
;//
;// * Redistributions in binary form must reproduce the above copyright notice,
;//   this list of conditions and the following disclaimer in the documentation
;//   and/or other materials provided with the distribution.
;//
;// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
;// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;// POSSIBILITY OF SUCH DAMAGE.
;//
//*****************************************************************************
//
// File:        <StructureName>MaintViewModel.cs
//
// Description: MVVM ViewModel class for structure <structure_name>
//
// Type:        Class
//
// Author:      <AUTHOR>
//
//*****************************************************************************
//
// WARNING:     This code was generated by CodeGen. Any changes that you make
//              to this file will be lost if the code is regenerated.
//
//*****************************************************************************
//
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Collections.ObjectModel;
using System.Windows.Input;

namespace <MVVM_DATA_NAMESPACE>
{
    public class <StructureName>MaintViewModel : DependencyObject
    {
        //Private data
        private <structure_name> m<StructureName>;

        //Constructor
        public <StructureName>MaintViewModel(<structure_name> <StructureName>Data)
        {
            //take the data
            m<StructureName> = <StructureName>Data;

            //these are the commands to bind against the buttons etc.
            this.LoadData = new <StructureName>MaintLoadCommand(this);
            this.SaveData = new <StructureName>MaintSaveCommand(this);
            this.CancelChanges = new <StructureName>MaintCancelCommand(this);
        }

        public <structure_name> <StructureName>Details
        {
            get { return m<StructureName>; }
            set { m<StructureName> = value; }
        }

        public ICommand LoadData { get; set; }
        public ICommand SaveData { get; set; }
        public ICommand CancelChanges { get; set; }

        public void RaiseMenuEvent(string menuName)
        {
            MenuSignal(menuName);
        }

        public delegate void MenuSignalEventHandler(string menuName);
        public event MenuSignalEventHandler MenuSignal;

    }

    #region Command classes

    public class <StructureName>MaintLoadCommand : ICommand
    {
        private <StructureName>MaintViewModel mVM;

        /// <summary>
        /// Constructor takes ViewModel as a dependency
        /// </summary>
        /// <param name="vm"></param>
        public <StructureName>MaintLoadCommand(<StructureName>MaintViewModel vm)
        {
            mVM = vm;
        }

        public bool CanExecute(object parameter)
        {
            return !string.IsNullOrEmpty(mVM.<StructureName>Details.<Primary_key_field>);
        }

        public event EventHandler CanExecuteChanged
        {
            add { CommandManager.RequerySuggested += value; }
            remove { CommandManager.RequerySuggested -= value; }
        }

        public void Execute(object parameter)
        {
            mVM.RaiseMenuEvent("LOAD");
        }
    }

    public class <StructureName>MaintSaveCommand : ICommand
    {
        private <StructureName>MaintViewModel mVM;

        /// <summary>
        /// constructor take view model as a dependancy
        /// </summary>
        /// <param name="vm"></param>
        public <StructureName>MaintSaveCommand(<StructureName>MaintViewModel vm)
        {
            mVM = vm;
        }

        public bool CanExecute(object parameter)
        {
            return !string.IsNullOrEmpty(mVM.<StructureName>Details.<Primary_key_field>);
        }

        public event EventHandler CanExecuteChanged
        {
            add { CommandManager.RequerySuggested += value; }
            remove { CommandManager.RequerySuggested -= value; }
        }

        public void Execute(object parameter)
        {
            mVM.RaiseMenuEvent("SAVE");
        }
    }

    public class <StructureName>MaintCancelCommand : ICommand
    {
        private <StructureName>MaintViewModel mVM;

        /// <summary>
        /// constructor take view model as a dependancy
        /// </summary>
        /// <param name="vm"></param>
        public <StructureName>MaintCancelCommand(<StructureName>MaintViewModel vm)
        {
            mVM = vm;
        }

        public bool CanExecute(object parameter)
        {
            return true;
        }

        public event EventHandler CanExecuteChanged
        {
            add { CommandManager.RequerySuggested += value; }
            remove { CommandManager.RequerySuggested -= value; }
        }

        public void Execute(object parameter)
        {
            mVM.RaiseMenuEvent("CANCEL");
        }
    }

    #endregion

}

