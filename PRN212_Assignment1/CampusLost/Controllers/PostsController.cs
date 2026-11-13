using CampusLost.Data;
using CampusLost.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CampusLost.Controllers;

public class PostsController(CampusLostDbContext context) : Controller
{
    [HttpGet]
    public async Task<IActionResult> Index([FromQuery] string? q, [FromQuery] int? kind)
    {
        var keyword = q?.Trim();
        var postsQuery = context.Posts.AsNoTracking();

        if (!string.IsNullOrEmpty(keyword))
        {
            postsQuery = postsQuery.Where(p => p.Title.Contains(keyword));
        }

        if (kind is 1 or 2)
        {
            postsQuery = postsQuery.Where(p => p.Kind == kind);
        }

        var posts = await postsQuery
            .OrderByDescending(p => p.PostedOn)
            .ThenByDescending(p => p.Id)
            .ToListAsync();
        ViewData["SearchQuery"] = keyword;
        ViewData["SelectedKind"] = kind is 1 or 2 ? kind : null;
        return View(posts);
    }

    public async Task<IActionResult> Details(int id)
    {
        var post = await context.Posts.AsNoTracking().SingleOrDefaultAsync(p => p.Id == id);
        return post is null ? NotFound() : View(post);
    }

    public IActionResult Create() => View(new LostItemPost());

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create([FromForm, Bind("Title,Kind,Location,Description,Contact")] LostItemPost post)
    {
        if (!ModelState.IsValid)
        {
            return View(post);
        }

        context.Posts.Add(post);
        await context.SaveChangesAsync();
        return RedirectToAction(nameof(Index));
    }
}
