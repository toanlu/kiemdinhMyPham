using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebBanMyPham.Models;
using PagedList;
using PagedList.Mvc;

namespace WebBanMyPham.Controllers
{
    public class HomeController : Controller
    {
        //
        // GET: /Home/
        DatabaseDataContext db = new DatabaseDataContext();
        
        public ActionResult Index(int? page)
        {
            var listSP = db.SANPHAMs.Join(db.DONGIAs,
                                    sp => sp.ID,
                                    donGia => donGia.ID_SP,
                                    (sp, donGia) => new SanPham
                                    {
                                        Id=sp.ID, 
                                        TenSP=sp.TENSP, 
                                        SoLuong=int.Parse(sp.SOLUONG.Value.ToString()), 
                                        HinhAnh=sp.HINHANH, 
                                        Gia=double.Parse(donGia.GIA.Value.ToString())
                                    }).ToList();
            return View(listSP.ToPagedList(page ?? 1, 12));
        }

        public ActionResult LienHe()
        {
            return View();
        }
    }
}
