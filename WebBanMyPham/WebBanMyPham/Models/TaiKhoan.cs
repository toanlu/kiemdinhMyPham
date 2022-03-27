using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebBanMyPham.Models
{
    public class TaiKhoan
    {
        string id_TK, username, pw;
        int id_gr;

        public int Id_gr
        {
            get { return id_gr; }
            set { id_gr = value; }
        }

        public string Id_TK
        {
            get { return id_TK; }
            set { id_TK = value; }
        }

        public string Pw
        {
            get { return pw; }
            set { pw = value; }
        }

        public string Username
        {
            get { return username; }
            set { username = value; }
        }
    }
}