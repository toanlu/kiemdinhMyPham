using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebBanMyPham.Models;

namespace WebBanMyPham.Controllers
{
    public class AdminController : Controller
    {
        //
        // GET: /Admin/
        DatabaseDataContext db = new DatabaseDataContext();

        public ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Index(FormCollection f)
        {
            string user = f["username"].ToString();
            string pw = f["pw"].ToString();

            // kiểm tra rỗng
            if (user.Trim().Length == 0 || pw.Trim().Length == 0) {
                ViewBag.Message = "Vui lòng nhập đủ thông tin";
                ViewBag.Info = "Empty";

                return View();
            }

            // ck trong db
            List<sp_CKAccResult> a = db.sp_CKAcc(user.Trim(), pw.Trim(), "Admin").ToList();
            string msg = a[0].Message;

            if (msg.Equals("SUCCESS"))
            {
                // lấy id tài khoản
                TAIKHOAN tk_ = db.TAIKHOANs.Single(tk => tk.USERNAME==user && tk.ID_GR==1);
                THONGTINTAIKHOAN ttnd_ = db.THONGTINTAIKHOANs.Single(ttnd => ttnd.ID_TAIKHOAN == tk_.ID);
                Session["ThongTinAdmin"] = new ThongTinNguoiDung { Tk = new TaiKhoan { Username=tk_.USERNAME }, HoTen=ttnd_.HOTEN };
                return RedirectToAction("QuanLy");
            }


            ViewBag.Message = msg;
            ViewBag.Info = "incorrect";

            return View();
        }

        public ActionResult QuanLy()
        {
            if (Session["ThongTinAdmin"] == null)
                return RedirectToAction("Index", "Admin");
            return View();
        }

    }
}
