# Django REST Framework

Assumes `conventions/django.md` also applies — this file only covers DRF-specific rules.

## Serializers
- Never use `fields = '__all__'` — list fields explicitly, so adding a model field doesn't silently expose it over the API.
- Validation logic (cross-field checks, business rules) lives in the serializer's `validate()`/`validate_<field>()`, not in the view. Validation that's really a domain rule (not request-shape validation) belongs in the service layer instead, called from `validate()`.
- Read and write concerns that diverge (e.g. nested writes, computed fields) get separate serializers (`FooReadSerializer`/`FooWriteSerializer`) rather than one serializer with a pile of conditional `SerializerMethodField`s.
- `SerializerMethodField` that hits the DB is an N+1 risk — prefetch/annotate on the queryset in the view, don't fetch inside the serializer.

## Views & viewsets
- `ModelViewSet` only when a resource genuinely needs the full CRUD set — a read-only resource is `ReadOnlyModelViewSet` or a plain `ListAPIView`/`RetrieveAPIView`, not a `ModelViewSet` with unused methods disabled.
- Override `get_queryset()` for anything scoped to the requesting user/tenant — never rely on serializer-level filtering to hide rows the queryset already returned.
- Custom `@action` methods re-check permissions the same as any other endpoint — an action route is not covered by the viewset's default permission check unless it actually runs through `get_permissions()`.
- Business logic (anything beyond parse → validate → call service → serialize response) does not belong in the view or viewset — call into `services.py`/`domain/`, matching `conventions/django.md`.

## Permissions & authentication
- Every `APIView`/`ViewSet` sets `permission_classes` explicitly — don't rely on the global `DEFAULT_PERMISSION_CLASSES` default for anything beyond truly public, read-only endpoints.
- Object-level permission checks (`has_object_permission`) are required for any endpoint that accepts a lookup id — a valid auth token is not the same as authorization to touch that specific object.
- New endpoints default to `IsAuthenticated` or stricter; `AllowAny` is an explicit, reviewed decision, matching the Django convention on anonymous access.

## Pagination & filtering
- Every list endpoint is paginated — either via `DEFAULT_PAGINATION_CLASS` or an explicit `pagination_class` on the view. An unpaginated list endpoint over a growing table is a production incident waiting to happen.
- Filtering/search/ordering go through `django-filter`'s `FilterSet` or `filter_backends`, not hand-parsed query params in the view.

## Errors & responses
- Raise DRF's `APIException` subclasses (or a project-specific subclass) for domain errors that should map to a specific HTTP status — don't return ad-hoc `Response({"error": ...}, status=...)` dicts scattered per view when the shape should be consistent.
- Use a custom `exception_handler` for cross-cutting error formatting instead of duplicating try/except-and-format blocks in every view.

## Testing
- `APITestCase`/`APIClient` (or `pytest-django`'s `APIClient` fixture) for endpoint tests — assert on status code and response body shape, not on view internals.
- Test permission boundaries explicitly: at least one test per endpoint asserting an unauthorized/wrong-tenant request is rejected, not just the happy path.
- Serializer validation logic gets direct unit tests (`serializer.is_valid()` + `serializer.errors`) separate from the view-level integration test.
